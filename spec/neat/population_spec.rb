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

  describe '#fitness' do
    subject { population.fitness }

    before { population.genomes.each { _1.fitness = rand } }

    it { is_expected.to eq(population.genomes.sum(&:fitness)) }
  end

  describe '#average_fitness' do
    subject { population.average_fitness }

    before { population.genomes.each { _1.fitness = rand } }

    it { is_expected.to eq(population.fitness / population.genomes.size) }
  end

  describe '#evolve' do
    subject(:evolve) { population.evolve }

    it 'calls #speciate' do
      expect(population).to receive(:speciate).once
      evolve
    end

    it 'increments the generation' do
      expect { evolve }.to change(population, :generation).by(1)
    end
  end

  describe '#speciate' do
    subject(:speciate) { population.speciate }

    it 'splits genomes into species' do
      expect { speciate }.to change(population.species, :size)

      expect(population.species).to all(be_a(Neat::Species))
      expect(population.genomes).to all(have_attributes(species: an_instance_of(Neat::Species)))
    end
  end
end
