# frozen_string_literal: true

require_relative 'weighted_random'

module Neat
  class Population
    include WeightedRandom

    attr_reader :neat, :size, :genomes, :species, :generation

    def initialize(neat:, size:)
      @neat = neat
      @size = size

      @genomes = Array.new(size) { @neat.create_genome }
      @species = []

      @generation = 1
    end

    def fitness
      @genomes.sum(&:fitness)
    end

    def average_fitness
      return 0 if @genomes.empty?

      fitness / @genomes.size
    end

    def evolve
      update_compatibility_threshold
      speciate
      prune_species
      clone_champions
      reproduce

      @generation += 1
    end

    # Split genomes into species
    def speciate(reset: true)
      # Reset existing species
      @species.each(&:reset) if reset

      @genomes.each do |genome|
        next if genome.species

        species = find_compatible_species(genome) || create_species(genome)
        species.add_genome(genome)
      end
    end

    # Prune species
    def prune_species
      population_fitness = fitness

      # Prune each species
      @species.each do |species|
        next if species.size <= 5

        species.prune(population_fitness)
      end

      # Remove genomes without species
      @genomes.filter!(&:species)
    end

    # Clone each species champion
    def clone_champions
      @new_population = @species.map { _1.champion.clone }
    end

    def reproduce
      return if @species.empty?

      while @new_population.size < @size
        species = choose(@species, :average_fitness)

        @new_population.push(species.crossover)
      end

      @genomes = @new_population
    end

    private

    extend Forwardable
    def_delegators :'Neat.config', :survival_threshold, :target_species, :species_compatibility_threshold

    def update_compatibility_threshold
      if @species.size < target_species
        ::Neat.config.species_compatibility_threshold = [species_compatibility_threshold - 0.1, 0.5].max.round(1)
      elsif @species.size > target_species
        ::Neat.config.species_compatibility_threshold = [species_compatibility_threshold + 0.1, 5.0].min.round(1)
      end
    end

    def find_compatible_species(genome)
      @species.find { _1.compatible?(genome) }
    end

    def create_species(genome)
      Species.new(representative: genome).tap do |species|
        @species.push(species)
      end
    end
  end
end
