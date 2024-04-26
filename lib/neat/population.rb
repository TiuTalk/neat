# frozen_string_literal: true

module Neat
  class Population
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
      speciate
      kill

      @generation += 1
    end

    # Split genomes into species
    def speciate
      @genomes.each do |genome|
        next if genome.species

        species = find_compatible_species(genome) || create_species(genome)
        species.add_genome(genome)
      end
    end

    # Kill off the weakest genomes of each species
    def kill
      @species.each(&:kill)
    end

    private

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
