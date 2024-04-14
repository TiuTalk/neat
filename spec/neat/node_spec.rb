# frozen_string_literal: true

RSpec.describe Neat::Node do
  subject(:node) { described_class.new(id: 1) }

  it { is_expected.to have_attributes(id: 1, type: :hidden) }

  describe '#to_s' do
    subject { node.to_s }

    it { is_expected.to eq("Node##{node.id} (#{node.type})") }
  end

  describe '#==' do
    context 'with Node with the same id' do
      let(:other) { described_class.new(id: node.id) }

      it { is_expected.to eq(other) }
      it { is_expected.to eql(other) }
      it { is_expected.to_not equal(other) }

      it 'has the same hash' do
        expect(node.hash).to eq(other.hash)
      end
    end

    context 'with Node with different id' do
      let(:other) { described_class.new(id: node.id + 1) }

      it { is_expected.to_not eq(other) }
      it { is_expected.to_not eql(other) }
      it { is_expected.to_not equal(other) }

      it 'does not have same hash' do
        expect(node.hash).to_not eq(other.hash)
      end
    end
  end

  described_class::TYPES.each do |type|
    describe "##{type}?" do
      subject(:node) { described_class.new(id: 1, type:) }

      it { is_expected.to send(:"be_#{type}") }
    end
  end
end
