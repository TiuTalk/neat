# frozen_string_literal: true

module Neat
  class Mutator
    MUTATION_METHODS = %i[add_node].freeze

    def initialize(genome)
      @genome = genome
    end

    def self.call(genome)
      new(genome).call
    end

    def call
      MUTATION_METHODS.each { send(_1) }
    end

    def add_node
      conn = @genome.connections.filter(&:enabled?).to_a.sample
      node = @genome.add_node(layer: conn.from.layer + 1)

      # Create the new connections
      @genome.add_connection(from: conn.from, to: node, weight: 1.0)
      @genome.add_connection(from: node, to: conn.to, weight: conn.weight)

      # Disable the old connection
      conn.enabled = false

      # TODO: Update the nodes layers

      node
    end
  end
end
