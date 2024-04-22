# frozen_string_literal: true

RSpec.describe Neat::Neat do
  subject(:neat) { described_class.new(inputs: 2, outputs: 1) }

  it { is_expected.to have_attributes(inputs: 2, outputs: 1, bias: true) }

  describe '#create_genome' do
    subject(:genome) { neat.create_genome }

    it 'returns a Genome object' do
      expect(genome).to be_a(Neat::Genome)
      expect(genome.nodes.count).to eq(2 + 1 + 1) # 2 inptus, 1 bias & 1 output
      expect(genome.connections.count).to eq(2 + 1) # (2 inptus + 1 bias) => 1 output
    end
  end

  describe '#add_node' do
    context 'with new Node' do
      it 'adds the Node' do
        expect do
          expect(neat.add_node).to be_truthy
        end.to change(neat, :nodes)

        node = neat.nodes.to_a.last

        expect(node).to be_a(Neat::Node)
        expect(node).to have_attributes(id: 1, type: :hidden)
      end
    end

    context 'with existing Node' do
      let!(:existing_node) { neat.add_node }

      it 'does not change the nodes' do
        expect { neat.add_node(id: existing_node.id) }.to_not change(neat, :nodes)
      end

      it 'returns the existing Node object' do
        node = neat.add_node(id: existing_node.id)

        expect(node).to equal(existing_node)
        expect(node.object_id).to eq(existing_node.object_id)
      end
    end
  end

  describe '#add_connection' do
    let(:from) { neat.add_node }
    let(:to) { neat.add_node }

    context 'with new Connection' do
      it 'adds the Connection' do
        expect do
          expect(neat.add_connection(from:, to:)).to be_truthy
        end.to change(neat, :connections)
      end

      it 'returns a new Connection object' do
        connection = neat.add_connection(from:, to:)

        expect(connection).to be_a(Neat::Connection)
        expect(connection).to have_attributes(id: 1, from:, to:)
      end
    end

    context 'with existing Connection' do
      let!(:existing_connection) { neat.add_connection(from:, to:) }

      it 'does not change the connections' do
        expect { neat.add_connection(from:, to:) }.to_not change(neat, :connections)
      end

      it 'returns a new Connection object' do
        connection = neat.add_connection(from:, to:)

        expect(connection).to have_attributes(id: existing_connection.id, from:, to:)
        expect(connection.weight).to_not eq(existing_connection.weight)
        expect(connection.object_id).to_not eq(existing_connection.object_id)
      end
    end
  end
end
