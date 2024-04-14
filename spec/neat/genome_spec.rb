# frozen_string_literal: true

RSpec.describe Neat::Genome do
  subject(:genome) { described_class.new }

  it { is_expected.to have_attributes(nodes: be_a(Set), connections: be_a(Set)) }

  describe '#add_node' do
    context 'with new Node' do
      it 'adds the Node' do
        expect do
          expect(genome.add_node).to be_truthy
        end.to change(genome, :nodes)

        node = genome.nodes.first

        expect(node).to be_a(Neat::Node)
        expect(node).to have_attributes(id: 1, type: :hidden)
      end
    end

    context 'with existing Node' do
      let!(:existing_node) { genome.add_node(id: 1) }

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
    let(:from) { genome.add_node }
    let(:to) { genome.add_node }

    context 'with new Connection' do
      it 'adds the Connection' do
        expect do
          expect(genome.add_connection(from:, to:)).to be_truthy
        end.to change(genome, :connections)

        connection = genome.connections.first

        expect(connection).to be_a(Neat::Connection)
        expect(connection).to have_attributes(id: 1, from:, to:)
      end
    end

    context 'with existing Connection' do
      let!(:existing_connection) { genome.add_connection(from:, to:) }

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
end
