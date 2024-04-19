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
    it 'runs all the mutation methods' do
      described_class::MUTATION_METHODS.each do |method|
        expect(mutator).to receive(method).ordered
      end

      mutator.call
    end
  end

  describe '#add_node' do
    let(:node) { genome.nodes.to_a.last }
    let(:connections) { genome.connections.to_a.last(2) }

    it 'adds a new hidden node to the genome' do
      expect { mutator.add_node }.to change(genome.nodes, :size).by(1)

      expect(node).to be_a(Neat::Node)
      expect(node).to have_attributes(id: genome.nodes.count, type: :hidden, layer: 2)
    end

    it 'adds two connections to the genome' do
      expect { mutator.add_node }.to change(genome.connections, :size).by(2)

      expect(connections[0]).to have_attributes(to: node, weight: 1.0)
      expect(connections[1]).to have_attributes(from: node)
    end

    it 'disables the old connection' do
      expect do
        mutator.add_node
      end.to change { genome.connections.count(&:disabled?) }.by(1)
    end

    it 'updates the nodes layers', pending: 'Not implemented yet' do
      mutator.add_node
      expect(genome.input_nodes).to all(have_attributes(type: :input, layer: 1))
      expect(genome.bias_nodes).to all(have_attributes(type: :bias, layer: 1))
      expect(genome.hidden_nodes).to all(have_attributes(type: :bias, layer: 2))
      expect(genome.output_nodes).to all(have_attributes(type: :output, layer: 3))
    end
  end
end
