# frozen_string_literal: true

require_relative 'weighted_random'

module Neat
  class Species
    include WeightedRandom

    attr_reader :representative, :genomes

    def initialize(representative:)
      raise ArgumentError, 'representative must be a Genome' unless representative.is_a?(Genome)

      @representative = representative
      @genomes = Set.new

      add_genome(representative)
    end

    def size
      @genomes.size
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
      parent_a.crossover(parent_b, mutate:)
    end

    def reset
      # Select a random new representative
      @repesentative = @genomes.to_a.sample

      @genomes.each { _1.species = nil }
      @genomes.clear

      add_genome(@representative)
    end

    def prune(population_fitness)
      return if fitness.zero? || population_fitness.zero?

      survivors = ((fitness / population_fitness * size) * survival_threshold).ceil
      to_prune = size - survivors

      return if to_prune <= 0

      @genomes.sort_by(&:fitness).first(to_prune).each { remove_genome(_1) }
    end

    private

    extend Forwardable
    def_delegators :'Neat.config', :survival_threshold

    # Selects a random genome using weighted fitness
    def random_genome
      choose(@genomes.to_a, :fitness)
    end

    extend Forwardable
    def_delegators :'Neat.config', :species_compatibility_threshold
  end
end
