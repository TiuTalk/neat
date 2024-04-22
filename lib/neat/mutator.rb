# frozen_string_literal: true

module Neat
  class Mutator
    def initialize(genome)
      @genome = genome
    end

    def self.call(genome)
      new(genome).call
    end

    def call
      if rand < Neat.config.mutation_add_node_probability
        add_node
      elsif rand < Neat.config.mutation_add_connection_probability
        add_connection
      elsif rand < Neat.config.mutation_mutate_weights_probability
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
      Neat.config.mutation_add_connection_tries.times do
        from, to = @genome.nodes.to_a.sample(2).sort_by(&:layer)

        # Skip nodes that cannot be connected
        next if from.output? || from.bias? || to.input? || to.bias?

        # Skip if the connection already exists
        next if @genome.connected?(from:, to:)

        # TODO: Check layers?
        # next if from.layer == to.layer

        # Create new connection
        @genome.add_connection(from:, to:)

        # Recalculate the layers
        @genome.recalculate_layers

        break
      end
    end

    def mutate_weights
      @genome.connections.each do |conn|
        if rand < Neat.config.mutation_randomize_weight_probability
          randomize_weight(conn)
        else
          perturb_weight(conn)
        end
      end
    end

    private

    def randomize_weight(conn)
      conn.weight = rand(Neat.config.connection_weight_range)
    end

    def perturb_weight(conn)
      conn.weight += rand(-0.1..0.1)
      conn.weight = conn.weight.clamp(Neat.config.connection_weight_range)
    end
  end
end
