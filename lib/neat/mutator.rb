# frozen_string_literal: true

module Neat
  class Mutator
    def initialize(genome)
      raise ArgumentError, 'genome must be a Genome' unless genome.is_a?(Genome)

      @genome = genome
    end

    def self.call(genome)
      new(genome).call
    end

    def call
      if rand < mutation_add_node_probability
        add_node
      elsif rand < mutation_add_connection_probability
        add_connection
      elsif rand < mutation_mutate_weights_probability
        mutate_weights
      end
    end

    def add_node
      conn = @genome.connections.filter(&:enabled?).to_a.sample
      node = @genome.add_node(layer: conn.from.layer + 1)

      # Create the new connections
      @genome.add_connection(from: conn.from, to: node, weight: 1.0)
      @genome.add_connection(from: node, to: conn.to, weight: conn.weight)

      # Disable the old connection
      conn.enabled = false

      # Recalculate the layers
      @genome.recalculate_layers

      node
    end

    def add_connection
      return if connection_candidates.empty?

      from, to = connection_candidates.sample

      # Create new connection
      @genome.add_connection(from:, to:)

      # Recalculate the layers
      @genome.recalculate_layers
    end

    def mutate_weights
      @genome.connections.each do |conn|
        if rand < mutation_randomize_weight_probability
          conn.randomize_weight
        else
          conn.perturb_weight
        end
      end
    end

    private

    extend Forwardable
    def_delegators :'Neat.config', :mutation_add_node_probability, :mutation_add_connection_probability,
      :mutation_mutate_weights_probability, :mutation_randomize_weight_probability

    def connection_candidates
      # Skip if the nodes are the same, the from node is in a higher layer, or the connection already exists
      @connection_candidates ||= connection_from_candidates.product(connection_to_candidates).reject do |from, to|
        from == to || from.layer >= to.layer || @genome.connected?(from:, to:)
      end
    end

    def connection_from_candidates
      @genome.nodes.reject { _1.output? || _1.bias? }
    end

    def connection_to_candidates
      @genome.nodes.reject { _1.input? || _1.bias? }
    end
  end
end
