RSpec.describe Neat::Node do
  describe '#id' do
    subject(:node) { described_class.new }

    it 'is not nil' do
      expect(node.id).to_not be_nil
      expect(node.id).to match(/\A[a-z0-9]+\z/)
    end
  end

  describe '#type' do
    context 'with input node' do
      subject(:node) { described_class.new(type: :input) }

      it 'is input' do
        expect(node.type).to eq(:input)
        expect(node).to be_input
      end
    end

    context 'with bias node' do
      subject(:node) { described_class.new(type: :bias) }

      it 'is bias' do
        expect(node.type).to eq(:bias)
        expect(node).to be_bias
      end
    end

    context 'with hidden node' do
      subject(:node) { described_class.new }

      it 'is hidden' do
        expect(node.type).to eq(:hidden)
        expect(node).to be_hidden
      end
    end

    context 'with output node' do
      subject(:node) { described_class.new(type: :output) }

      it 'is output' do
        expect(node.type).to eq(:output)
        expect(node).to be_output
      end
    end
  end

  describe '#to_s' do
    subject(:node) { described_class.new(type: :bias) }

    it 'contains the type and the ID' do
      expect(node.to_s).to eq("Bias##{node.id}")
    end
  end
end
