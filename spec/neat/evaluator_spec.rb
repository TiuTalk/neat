# frozen_string_literal: true

RSpec.describe Neat::Evaluator do
  subject(:evaluator) { described_class.new(genome) }

  let(:genome) { Neat::Genome.new(inputs: 2, outputs: 1) }

  before do
    genome.connections.each { _1.weight = 0.5 }
  end

  describe '.call' do
    it 'creates a new instance and calls it' do
      evaluator = instance_double(described_class)

      allow(described_class).to receive(:new).with(genome).and_return(evaluator)
      expect(evaluator).to receive(:call).with([0.1, 0.2])

      described_class.call(genome, [0.1, 0.2])
    end
  end

  describe '#call' do
    it 'evaluates the genome' do
      outputs = evaluator.call([0.1, 0.2])

      expect(outputs.size).to eq(1)
      expect(outputs).to all(be_a(Float))

      # TODO: Verify the output value
      expect(outputs[0]).to eq(0.6570104626734988)
    end
  end
end
