# frozen_string_literal: true

require 'pry'
require 'neat'

# Seed
seed = ARGV[0] == '--seed' ? ARGV[1].to_i : Random.new_seed
puts "Seed: #{seed}"
Kernel.srand(seed)

TESTS = {
  [0, 0] => 0,
  [0, 1] => 1,
  [1, 0] => 1,
  [1, 1] => 0
}.freeze

neat = Neat::Neat.new(inputs: 2, outputs: 1)
populaton = Neat::Population.new(neat:, size: 100)
generations = 100

precision = 5
best_genome = nil

generations.times do
  populaton.genomes.each do |genome|
    genome.fitness = 4.0

    TESTS.each do |input, expected|
      output = genome.evaluate(input)[0]
      genome.fitness -= (output - expected).abs**2
    end
  end

  best_genome = populaton.genomes.max_by(&:fitness)

  puts [
    "Gen #{populaton.generation.to_s.rjust(3)}",
    "Genomes: #{populaton.genomes.size.to_s.rjust(3)}",
    "Species: #{populaton.species.size.to_s.rjust(2)}",
    "Theshold: #{Neat.config.species_compatibility_threshold.to_s.rjust(4)}",
    "Avg fitness: #{populaton.average_fitness.round(precision)}",
    "Best fitness: #{best_genome.fitness.round(precision)}"
  ].join(' | ')

  populaton.evolve
end

puts "\nBest genome:"
puts "Fitness: #{best_genome.fitness}"
puts "Nodes: #{best_genome.nodes.size}"
puts "Connections: #{best_genome.connections.size}"
puts 'Network:'
puts best_genome.connections.map(&:to_s)

puts "\nTest results:"
TESTS.each do |input, expected|
  output = best_genome.evaluate(input)[0]
  puts "#{input.join(' ^ ')} = #{output.round(3)} (expected #{expected})"
end
