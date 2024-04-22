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
end
