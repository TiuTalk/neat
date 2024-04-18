# frozen_string_literal: true

module Neat
  class Evaluator
    def initialize(genome)
      @genome = genome
    end

    def self.call(genome, inputs)
      new(genome).call(inputs)
    end

    def call(inputs)
      # Reset the outputs
      @outputs = {}

      initialize_inputs(inputs)

      @genome.output_nodes.sort_by(&:id).map { evaluate_node(_1) }
    end

    private

    def activation_function
      @activation_function ||= Neat.config.activation_function
    end

    def evaluate_node(node)
      @outputs[node.id] ||= begin
        value = @genome.connections_to(node).sum { evaluate_connection(_1) }

        activation_function.call(value)
      end
    end

    # TODO: Check if this method needs a cache/memoization
    def evaluate_connection(connection)
      return 0 if connection.disabled?

      evaluate_node(connection.from) * connection.weight
    end

    def initialize_inputs(inputs)
      raise ArgumentError, 'Invalid inputs size' unless inputs.size == @genome.input_nodes.size

      # Initialize input nodes
      @genome.input_nodes.zip(inputs).each do |node, value|
        @outputs[node.id] = value
      end

      # Initialize bias nodes
      @genome.bias_nodes.each { |node| @outputs[node.id] = 1.0 }
    end
  end
end
