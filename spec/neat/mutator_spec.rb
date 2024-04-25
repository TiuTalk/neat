# frozen_string_literal: true

RSpec.describe Neat::Mutator do
  subject(:mutator) { described_class.new(genome) }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }
  let(:genome) { neat.create_genome }

  describe '#mutate' do
    subject(:mutate) { mutator.mutate }

    before do
      allow(Neat.config).to receive_messages({
        mutation_add_node_chance: 0.0,
        mutation_add_connection_chance: 0.0,
        mutation_mutate_weights_chance: 0.0
      })
    end

    context 'when mutation_add_node_chance is 100%' do
      before { allow(Neat.config).to receive(:mutation_add_node_chance).and_return(1.0) }

      it 'calls #add_node' do
        expect(mutator).to receive(:add_node)
        mutate
      end
    end

    context 'when mutation_add_connection_chance is 100%' do
      before { allow(Neat.config).to receive(:mutation_add_connection_chance).and_return(1.0) }

      it 'calls #add_connection' do
        expect(mutator).to receive(:add_connection)
        mutate
      end
    end

    context 'when mutation_mutate_weights_chance is 100%' do
      before { allow(Neat.config).to receive(:mutation_mutate_weights_chance).and_return(1.0) }

      it 'calls #mutate_weights' do
        expect(mutator).to receive(:mutate_weights)
        mutate
      end
    end
  end

  describe '#add_node' do
    subject(:mutation) { mutator.add_node }

    let(:node) { genome.nodes.to_a.last }
    let(:connections) { genome.connections.to_a.last(2) }

    it 'adds a new hidden node to the genome' do
      expect { mutation }.to change(genome.nodes, :size).by(1)

      expect(node).to be_a(Neat::Node)
      expect(node).to have_attributes(id: genome.nodes.count, type: :hidden, layer: 2)
    end

    it 'adds two connections to the genome' do
      expect { mutation }.to change(genome.connections, :size).by(2)

      expect(connections[0]).to have_attributes(to: node, weight: 1.0)
      expect(connections[1]).to have_attributes(from: node)
    end

    it 'disables the old connection' do
      expect do
        mutation
      end.to change { genome.connections.count(&:disabled?) }.by(1)
    end

    it 'updates the genome layers' do
      mutation

      expect(genome.input_nodes).to all(have_attributes(type: :input, layer: 1))
      expect(genome.bias_nodes).to all(have_attributes(type: :bias, layer: 1))
      expect(genome.hidden_nodes).to all(have_attributes(type: :hidden, layer: 2))
      expect(genome.output_nodes).to all(have_attributes(type: :output, layer: 3))
    end

    context 'with other genomes' do
      let!(:other) { neat.create_genome }

      it 'does not affect other Genomes' do
        expect { mutation }.to_not change(other, :nodes)
      end
    end
  end

  describe '#add_connection' do
    subject(:mutation) { mutator.add_connection }

    context 'when connection is possible' do
      before { mutator.add_node }

      it 'adds a new connection to the genome' do
        expect { mutation }.to change(genome.connections, :size).by(1)
      end

      it 'updates the genome layers' do
        mutation

        expect(genome.input_nodes).to all(have_attributes(type: :input, layer: 1))
        expect(genome.bias_nodes).to all(have_attributes(type: :bias, layer: 1))
        expect(genome.hidden_nodes).to all(have_attributes(type: :hidden, layer: 2))
        expect(genome.output_nodes).to all(have_attributes(type: :output, layer: 3))
      end
    end

    context 'when connection is not possible' do
      it 'does not add a new connection to the genome' do
        expect { mutation }.to_not change(genome.connections, :size)
      end
    end

    context 'with other genomes' do
      let!(:other) { neat.create_genome }

      before { mutator.add_node }

      it 'does not affect other Genomes' do
        expect { mutation }.to_not change(other, :connections)
      end
    end
  end

  describe '#mutate_weights' do
    subject(:mutation) { mutator.mutate_weights }

    context 'when weights are randomized' do
      before { allow(Neat.config).to receive(:mutation_randomize_weight_chance).and_return(1.0) }

      it 'randomizes the weights of the connections' do
        sum = genome.connections.sum(&:weight)
        expect { mutation }.to(change { genome.connections.map(&:weight) })
        expect(genome.connections.sum(&:weight)).to_not eq sum
      end

      it 'keeps the weights within the range' do
        mutation

        genome.connections.each do |conn|
          expect(conn.weight).to be_between(*Neat.config.connection_weight_range.minmax)
        end
      end
    end

    context 'when weights are perturbed' do
      before { allow(Neat.config).to receive(:mutation_randomize_weight_chance).and_return(0) }

      it 'perturbs the weights of the connections' do
        weights_before = genome.connections.map(&:weight)

        expect { mutation }.to(change { genome.connections.map(&:weight) })

        genome.connections.each.with_index do |conn, i|
          change = (conn.weight - weights_before[i]) / weights_before[i]
          expect(change).to be_between(*Neat.config.mutation_perturb_weight_range.minmax)
        end
      end

      it 'keeps the weights within the range' do
        mutation

        genome.connections.each do |conn|
          expect(conn.weight).to be_between(*Neat.config.connection_weight_range.minmax)
        end
      end
    end

    context 'with other genomes' do
      let!(:other) { neat.create_genome }

      it 'does not affect other Genomes' do
        expect { mutation }.to_not(change { other.connections.map(&:weight) })
      end
    end
  end
end
