# frozen_string_literal: true

RSpec.describe Neat::Mutator do
  subject(:mutator) { described_class.new(genome) }

  let(:genome) { Neat::Genome.new(inputs: 2, outputs: 1) }

  describe '.call' do
    it 'creates a new instance and calls it' do
      mutator = instance_double(described_class)

      allow(described_class).to receive(:new).with(genome).and_return(mutator)
      expect(mutator).to receive(:call)

      described_class.call(genome)
    end
  end

  describe '#call' do
    before do
      allow(Neat.config).to receive_messages({
        mutation_add_node_probability: 0.0,
        mutation_add_connection_probability: 0.0,
        mutation_mutate_weights_probability: 0.0
      })
    end

    context 'when mutation_add_node_probability is 100%' do
      before { allow(Neat.config).to receive(:mutation_add_node_probability).and_return(1.0) }

      it 'calls #add_node' do
        expect(mutator).to receive(:add_node)
        mutator.call
      end
    end

    context 'when mutation_add_connection_probability is 100%' do
      before { allow(Neat.config).to receive(:mutation_add_connection_probability).and_return(1.0) }

      it 'calls #add_connection' do
        expect(mutator).to receive(:add_connection)
        mutator.call
      end
    end

    context 'when mutation_mutate_weights_probability is 100%' do
      before { allow(Neat.config).to receive(:mutation_mutate_weights_probability).and_return(1.0) }

      it 'calls #mutate_weights' do
        expect(mutator).to receive(:mutate_weights)
        mutator.call
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
  end

  describe '#add_connection' do
    subject(:mutation) { mutator.add_connection }

    context 'when connection is possible' do
      before do
        mutator.add_node
        allow(Neat.config).to receive(:mutation_add_connection_tries).and_return(50)
      end

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
      before { allow(Neat.config).to receive(:mutation_add_connection_tries).and_return(5) }

      it 'does not add a new connection to the genome' do
        expect { mutation }.to_not change(genome.connections, :size)
      end
    end
  end

  describe '#mutate_weights' do
    context 'when weights are randomized' do
      before { allow(Neat.config).to receive(:mutation_randomize_weight_probability).and_return(1.0) }

      it 'randomizes the weights of the connections' do
        sum = genome.connections.sum(&:weight)
        expect { mutator.mutate_weights }.to(change { genome.connections.map(&:weight) })
        expect(genome.connections.sum(&:weight)).to_not eq sum
      end
    end

    context 'when weights are perturbed' do
      before { allow(Neat.config).to receive(:mutation_randomize_weight_probability).and_return(0) }

      it 'perturbs the weights of the connections' do
        sum = genome.connections.sum(&:weight)
        expect { mutator.mutate_weights }.to(change { genome.connections.map(&:weight) })
        expect(genome.connections.sum(&:weight)).to_not eq sum
      end
    end
  end
end
