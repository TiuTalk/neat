# frozen_string_literal: true

module Neat
  class Species
    attr_reader :representative, :genomes

    def initialize(representative:)
      raise ArgumentError, 'representative must be a Genome' unless representative.is_a?(Genome)

      @representative = representative
      @genomes = Set.new([representative])
    end

    def add_genome(genome)
      @genomes.add?(genome)
    end

    def remove_genome(genome)
      @genomes.delete(genome)

      # Select a new representative if the current one was removed
      @representative = @genomes.to_a.sample if genome == @representative
    end

    def compatible?(genome)
      distance(genome) <= species_compatibility_threshold
    end

    def distance(genome)
      @representative.distance(genome)
    end

    def crossover(mutate: true)
      parent_a = random_genome
      parent_b = random_genome

      # Create a new genome by crossing over the parents
      parent_a.crossover(parent_b, mutate:).tap do |child|
        add_genome(child)
      end
    end

    private

    # TODO: Implement a better selection method
    def random_genome
      @genomes.to_a.sample
    end

    extend Forwardable
    def_delegators :'Neat.config', :species_compatibility_threshold
  end
end
