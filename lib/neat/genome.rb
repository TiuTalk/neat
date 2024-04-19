# frozen_string_literal: true

require_relative 'node'
require_relative 'connection'
require_relative 'evaluator'
require_relative 'mutator'

module Neat
  class Genome
    attr_reader :nodes, :connections

    def initialize(inputs:, outputs:, bias: true, connected: true)
      @nodes = Set.new
      @connections = Set.new

      return unless connected

      initialize_nodes(inputs:, outputs:, bias:)
      initialize_connections
    end

    Node::TYPES.each do |type|
      define_method(:"#{type}_nodes") { @nodes.select(&:"#{type}?") }
    end

    def connections_from(node) = @connections.select { _1.from == node }
    def connections_to(node) = @connections.select { _1.to == node }

    def connected?(from:, to:)
      @connections.any? { (_1.from == from && _1.to == to) || (_1.from == to && _1.to == from) }
    end

    def add_node(**args)
      # TODO: Remove this
      args[:id] ||= @nodes.count + 1

      node = Node.new(**args)

      if @nodes.add?(node)
        node
      else
        @nodes.find { _1 == node }
      end
    end

    def add_connection(**args)
      # TODO: Remove this
      args[:id] ||= @connections.count + 1

      conn = Connection.new(**args)

      if @connections.add?(conn)
        conn
      else
        @connections.find { _1 == conn }
      end
    end

    def recalculate_layers
      reset_node_layers

      # Recalculate node layers
      @nodes.each { _1.layer = node_depth(_1) + 1 }

      # Group output nodes in the same layer
      layer = output_nodes.map(&:layer).max
      output_nodes.each { _1.layer = layer }
    end

    def evaluate(inputs)
      Evaluator.new(self).call(inputs)
    end

    def mutate
      Mutator.new(self).call
    end

    private

    def initialize_nodes(inputs:, outputs:, bias:)
      inputs.times { add_node(id: @nodes.count + 1, type: :input, layer: 1) }

      add_node(id: @nodes.count + 1, type: :bias, layer: 1) if bias

      outputs.times { add_node(id: @nodes.count + 1, type: :output, layer: 2) }
    end

    def initialize_connections
      (input_nodes + bias_nodes).product(output_nodes).each do |from, to|
        add_connection(id: @connections.count + 1, from:, to:)
      end
    end

    def reset_node_layers
      @nodes.each { _1.layer = nil }
      @node_depth = {}
    end

    def node_depth(node)
      return 0 if node.input? || node.bias?

      @node_depth[node.id] ||= connections_to(node).map { node_depth(_1.from) }.max + 1
    end
  end
end
