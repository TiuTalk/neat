# frozen_string_literal: true

RSpec.describe Neat::Species do
  subject(:species) { described_class.new(representative:) }

  let(:neat) { Neat::Neat.new(inputs: 2, outputs: 1) }
  let(:representative) { neat.create_genome }
  let(:genome) { neat.create_genome }

  it { is_expected.to have_attributes(representative:) }

  describe '#genomes' do
    before { species.add_genome(genome) }

    it 'returns the genomes in the species' do
      expect(species.genomes).to include(representative, genome)
    end
  end

  describe '#champion' do
    before do
      species.add_genome(genome)
      species.genomes.each { _1.fitness = rand }
    end

    it 'returns the genome with the highest fitness' do
      expect(species.champion).to eq(species.genomes.max_by(&:fitness))
    end
  end

  describe '#fitness' do
    subject { species.fitness }

    before do
      species.add_genome(genome)
      species.genomes.each { _1.fitness = rand }
    end

    it { is_expected.to eq(species.genomes.sum(&:fitness)) }
  end

  describe '#average_fitness' do
    subject { species.average_fitness }

    before do
      species.add_genome(genome)
      species.genomes.each { _1.fitness = rand }
    end

    it { is_expected.to eq(species.fitness / species.genomes.size) }
  end

  describe '#add_genome' do
    it 'adds a genome to the species' do
      expect { species.add_genome(genome) }.to change(species.genomes, :count).by(1)
      expect(species.genomes).to include(genome)
    end

    it 'updates the genome species' do
      expect { species.add_genome(genome) }.to change(genome, :species)
      expect(genome.species).to eq(species)
    end
  end

  describe '#remove_genome' do
    before { species.add_genome(genome) }

    context 'with a normal genome' do
      it 'removes the genome from the species' do
        expect { species.remove_genome(genome) }.to change(species.genomes, :count).by(-1)
        expect(species.genomes).to_not include(genome)
      end

      it 'does not change the representative' do
        expect { species.remove_genome(genome) }.to_not change(species, :representative)
      end
    end

    context 'with the representative' do
      it 'removes the genome from the species' do
        expect { species.remove_genome(representative) }.to change(species.genomes, :count).by(-1)
        expect(species.genomes).to_not include(representative)
      end

      it 'selects a new representative' do
        expect { species.remove_genome(representative) }.to change(species, :representative)
        expect(species.representative).to eq(genome)
      end
    end
  end

  describe '#compatible?' do
    context 'when the species_compatibility_threshold is high' do
      before { allow(Neat.config).to receive(:species_compatibility_threshold).and_return(5.0) }

      it { is_expected.to be_compatible(representative) }
      it { is_expected.to be_compatible(genome) }
    end

    context 'when the species_compatibility_threshold is low' do
      before { allow(Neat.config).to receive(:species_compatibility_threshold).and_return(0.0) }

      it { is_expected.to be_compatible(representative) }
      it { is_expected.to_not be_compatible(genome) }
    end
  end

  describe '#distance' do
    subject(:distance) { species.distance(genome) }

    it 'returns the distance between the representative and a genome' do
      expected = representative.distance(genome)

      expect(distance).to be_a(Float)
      expect(distance).to eq(expected)
    end
  end

  describe '#crossover' do
    subject(:offspring) { species.crossover }

    it 'returns a new genome' do
      expect(offspring).to be_a(Neat::Genome)
      expect(offspring).to_not eq(representative)
    end

    it 'includes the offspring in the species' do
      expect { offspring }.to change(species.genomes, :count).by(1)
      expect(species.genomes).to include(offspring)
    end
  end
end
