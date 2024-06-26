# frozen_string_literal: true

RSpec.describe Neat::Connection do
  subject(:conn) { described_class.new(id: 1, from:, to:) }

  let(:from) { Neat::Node.new(id: 1) }
  let(:to) { Neat::Node.new(id: 2) }

  it { is_expected.to have_attributes(id: 1, from:, to:, weight: be_a(Float), enabled: true) }

  describe '#weight' do
    it 'is within the weight range' do
      range = Neat.config.connection_weight_range
      expect(range).to cover(conn.weight)
    end
  end

  describe '#enabled?' do
    it { is_expected.to be_enabled }
    it { is_expected.to_not be_disabled }
  end

  describe '#disabled?' do
    subject(:conn) { described_class.new(id: 1, from:, to:, enabled: false) }

    it { is_expected.to be_disabled }
    it { is_expected.to_not be_enabled }
  end

  describe '#to_s' do
    subject { conn.to_s }

    it { is_expected.to eq("Connection##{conn.id} (#{from.id} => #{to.id}) #{conn.weight}") }
  end

  describe '#==' do
    context 'with Connection between the same Nodes' do
      let(:other) { described_class.new(id: conn.id, from:, to:) }

      it { is_expected.to eq(other) }
      it { is_expected.to eql(other) }
      it { is_expected.to_not equal(other) }

      it 'has the same hash' do
        expect(conn.hash).to eq(other.hash)
      end
    end

    context 'with Connection between different Nodes' do
      let(:other) { described_class.new(id: conn.id, from:, to: Neat::Node.new(id: 3)) }

      it { is_expected.to_not eq(other) }
      it { is_expected.to_not eql(other) }
      it { is_expected.to_not equal(other) }

      it 'does not have same hash' do
        expect(conn.hash).to_not eq(other.hash)
      end
    end
  end

  describe '#clone' do
    subject(:clone) { conn.clone }

    it 'returns a new Connection object' do
      expect(clone).to be_a(described_class)
      expect(clone).to have_attributes(id: conn.id, from:, to:)
      expect(clone).to_not equal(conn)
      expect(clone.object_id).to_not equal(conn.object_id)
    end
  end

  describe '#randomize_weight' do
    subject(:randomize_weight) { conn.randomize_weight }

    it 'changes the weight' do
      expect { randomize_weight }.to change(conn, :weight)
    end
  end

  describe '#perturb_weight' do
    subject(:perturb_weight) { conn.perturb_weight }

    it 'changes the weight' do
      expect { perturb_weight }.to change(conn, :weight)
    end
  end
end
