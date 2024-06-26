# frozen_string_literal: true

RSpec.describe Neat::Evaluator do
  subject(:evaluator) { described_class.new(genome) }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }
  let(:genome) { neat.create_genome }

  let(:inputs) { Array.new(2) { rand(-10.0..10.0) } }
  let(:activation_function) { Neat.config.activation_function }

  before do
    genome.connections.each { _1.weight = 0.5 }
  end

  describe '#evaluate' do
    subject(:outputs) { evaluator.evaluate(inputs) }

    it 'evaluates the genome' do
      values = [(0.5 * inputs[0]), (0.5 * inputs[1]), (0.5 * 1.0)]
      expected = activation_function.call(values.sum)

      expect(outputs).to eq([expected])
    end

    context 'with disabled connections' do
      before { genome.connections.first.enabled = false }

      it 'ignores disabled connections' do
        values = [(0.5 * inputs[1]), (0.5 * 1.0)]
        expected = activation_function.call(values.sum)

        expect(outputs).to eq([expected])
      end
    end
  end
end
