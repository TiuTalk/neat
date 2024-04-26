# frozen_string_literal: true

module Neat
  class Species
    attr_reader :representative, :genomes

    def initialize(representative:)
      raise ArgumentError, 'representative must be a Genome' unless representative.is_a?(Genome)

      @representative = representative
      @genomes = Set.new

      add_genome(representative)
    end

    def champion
      @genomes.max_by(&:fitness)
    end

    def fitness
      @genomes.sum(&:fitness)
    end

    def average_fitness
      return 0 if @genomes.empty?

      fitness / @genomes.size
    end

    def add_genome(genome)
      return unless @genomes.add?(genome)

      genome.species = self
    end

    def remove_genome(genome)
      @genomes.delete(genome)
      genome.species = nil

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

    def kill
      # Don't kill the last genome
      return if @genomes.size <= 1

      survivors = (@genomes.size * survival_threshold).ceil
      to_kill = @genomes.size - survivors

      return if to_kill <= 0

      @genomes.sort_by(&:fitness).take(to_kill).each do |genome|
        # TODO: Implement a way to mark genomes as dead
      end
    end

    private

    extend Forwardable
    def_delegators :'Neat.config', :survival_threshold

    # TODO: Implement a better selection method
    def random_genome
      @genomes.to_a.sample
    end

    extend Forwardable
    def_delegators :'Neat.config', :species_compatibility_threshold
  end
end
