# frozen_string_literal: true

RSpec.describe Neat::Population do
  subject(:population) { described_class.new(neat:, size: 5) }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }

  it { is_expected.to have_attributes(neat:, size: 5) }

  describe '#genomes' do
    it 'returns an array of genomes' do
      expect(population.genomes).to all(be_a(Neat::Genome))
      expect(population.genomes.size).to eq(5)
    end
  end

  describe '#species' do
    it 'returns an array of species' do
      expect(population.species).to all(be_a(Neat::Species))
    end
  end

  describe '#evolve' do
    it 'calls #speciate' do
      expect(population).to receive(:speciate).once
      population.evolve
    end
  end

  describe '#speciate' do
    it 'splits genomes into species' do
      expect { population.send(:speciate) }.to change(population.species, :size)

      expect(population.species).to all(be_a(Neat::Species))
      expect(population.genomes).to all(have_attributes(species: an_instance_of(Neat::Species)))
    end
  end
end
