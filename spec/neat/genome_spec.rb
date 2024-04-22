# frozen_string_literal: true

RSpec.describe Neat::Genome do
  subject(:genome) { neat.create_genome }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }

  it { is_expected.to have_attributes(nodes: be_a(Set), connections: be_a(Set)) }

  describe '#initialize' do
    it 'initializes the genome nodes' do
      expect(genome.nodes.count).to eq(2 + 1 + 1) # 2 inptus, 1 bias & 1 output

      # Check the nodes types count
      expect(genome.nodes.map(&:type).tally).to eq(input: 2, bias: 1, output: 1)

      # Check the nodes types and layers
      expect(genome.input_nodes).to all(have_attributes(type: :input, layer: 1))
      expect(genome.bias_nodes).to all(have_attributes(type: :bias, layer: 1))
      expect(genome.output_nodes).to all(have_attributes(type: :output, layer: 2))
    end

    it 'initializes the genome connections' do
      expect(genome.connections.count).to eq(2 + 1) # (2 inptus + 1 bias) => 1 output
      expect(genome.connections).to all(be_a(Neat::Connection))
    end

    context 'when not connected' do
      subject(:genome) { neat.create_genome(connected: false) }

      it 'does not initialize the genome' do
        expect(genome.nodes).to be_empty
        expect(genome.connections).to be_empty
      end
    end
  end

  Neat::Node::TYPES.each do |type|
    describe "##{type}_nodes" do
      subject(:nodes) { genome.send(:"#{type}_nodes") }

      it "returns the genome #{type} nodes" do
        expect(nodes).to all(be_a(Neat::Node))
        expect(nodes).to all(have_attributes(type:))
      end
    end
  end

  describe '#connections_from' do
    it 'returns the connections from the node' do
      node = genome.input_nodes.first

      expect(genome.connections_from(node)).to all(be_a(Neat::Connection))
      expect(genome.connections_from(node)).to all(have_attributes(from: node))
    end
  end

  describe '#connections_to' do
    it 'returns the connections to the node' do
      node = genome.output_nodes.first

      expect(genome.connections_to(node)).to all(be_a(Neat::Connection))
      expect(genome.connections_to(node)).to all(have_attributes(to: node))
    end
  end

  describe '#add_node' do
    it 'adds the Node' do
      expect do
        expect(genome.add_node).to be_truthy
      end.to change(genome, :nodes)

      node = genome.nodes.to_a.last

      expect(node).to be_a(Neat::Node)
      expect(node).to have_attributes(id: 5, type: :hidden)
    end
  end

  describe '#add_connection' do
    let(:from) { genome.input_nodes.first }
    let(:to) { genome.add_node }

    it 'adds the Connection' do
      expect do
        expect(genome.add_connection(from:, to:)).to be_truthy
      end.to change(genome, :connections)

      connection = genome.connections.to_a.last

      expect(connection).to be_a(Neat::Connection)
      expect(connection).to have_attributes(id: 4, from:, to:)
    end
  end

  describe '#recalculate_layers' do
    before { genome.nodes.each { |node| node.layer = nil } }

    it 'recalculates the nodes layers' do
      genome.recalculate_layers

      expect(genome.input_nodes).to all(have_attributes(type: :input, layer: 1))
      expect(genome.bias_nodes).to all(have_attributes(type: :bias, layer: 1))
      expect(genome.output_nodes).to all(have_attributes(type: :output, layer: 2))
    end
  end

  describe '#evaluate' do
    let(:evaluator) { instance_double(Neat::Evaluator) }

    it 'calls the Evaluator' do
      allow(Neat::Evaluator).to receive(:new).with(genome).and_return(evaluator)
      expect(evaluator).to receive(:call).with([1, 2])

      genome.evaluate([1, 2])
    end
  end

  describe '#mutate' do
    let(:mutator) { instance_double(Neat::Mutator) }

    it 'calls the Mutator' do
      allow(Neat::Mutator).to receive(:new).with(genome).and_return(mutator)
      expect(mutator).to receive(:call)

      genome.mutate
    end
  end
end
