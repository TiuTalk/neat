# frozen_string_literal: true

RSpec.describe Neat::Genome do
  subject(:genome) { described_class.new(inputs: 2, outputs: 1) }

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
      subject(:genome) { described_class.new(inputs: 2, outputs: 1, connected: false) }

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
    context 'with new Node' do
      it 'adds the Node' do
        expect do
          expect(genome.add_node).to be_truthy
        end.to change(genome, :nodes)

        node = genome.nodes.to_a.last

        expect(node).to be_a(Neat::Node)
        expect(node).to have_attributes(id: 5, type: :hidden)
      end
    end

    context 'with existing Node' do
      let!(:existing_node) { genome.input_nodes.first }

      it 'does not change the nodes' do
        expect { genome.add_node(id: 1) }.to_not change(genome, :nodes)
      end

      it 'returns the existing Node' do
        node = genome.add_node(id: 1)

        expect(node).to equal(existing_node)
        expect(node.object_id).to eq(existing_node.object_id)
      end
    end
  end

  describe '#add_connection' do
    context 'with new Connection' do
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

    context 'with existing Connection' do
      let!(:existing_connection) { genome.connections.first }

      let(:from) { existing_connection.from }
      let(:to) { existing_connection.to }

      it 'does not change the connections' do
        expect { genome.add_connection(from:, to:) }.to_not change(genome, :connections)
      end

      it 'returns the existing Connection' do
        connection = genome.add_connection(from:, to:)

        expect(connection).to equal(existing_connection)
        expect(connection.object_id).to eq(existing_connection.object_id)
      end
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
end
