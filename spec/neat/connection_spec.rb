# frozen_string_literal: true

RSpec.describe Neat::Connection do
  subject(:conn) { described_class.new(id: 1, from:, to:) }

  let(:from) { Neat::Node.new(id: 1) }
  let(:to) { Neat::Node.new(id: 2) }

  it { is_expected.to have_attributes(id: 1, from:, to:, weight: be_between(-2.0, 2.0), enabled: true) }

  describe '#to_s' do
    subject { conn.to_s }

    it { is_expected.to eq("Connection##{conn.id} (#{from.id} -> #{to.id})") }
  end

  describe '#==' do
    context 'with Connection between the same Nodes' do
      let(:other) { described_class.new(id: conn.id, from:, to:) }

      it { is_expected.to eq(other) }
      it { is_expected.to eql(other) }
      it { is_expected.to_not equal(other) }
    end

    context 'with Connection between different Nodes' do
      let(:other) { described_class.new(id: conn.id, from:, to: Neat::Node.new(id: 3)) }

      it { is_expected.to_not eq(other) }
      it { is_expected.to_not eql(other) }
      it { is_expected.to_not equal(other) }
    end
  end
end
