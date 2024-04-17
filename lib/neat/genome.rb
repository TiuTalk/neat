# frozen_string_literal: true

require_relative 'node'
require_relative 'connection'

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

    def add_node(**args)
      args[:id] ||= @nodes.count + 1

      node = Node.new(**args)

      if @nodes.add?(node)
        node
      else
        @nodes.find { _1 == node }
      end
    end

    def add_connection(**args)
      args[:id] ||= @connections.count + 1

      conn = Connection.new(**args)

      if @connections.add?(conn)
        conn
      else
        @connections.find { _1 == conn }
      end
    end

    private

    def initialize_nodes(inputs:, outputs:, bias:)
      inputs.times { add_node(type: :input) }

      add_node(type: :bias) if bias

      outputs.times { add_node(type: :output) }
    end

    def initialize_connections
      (input_nodes + bias_nodes).product(output_nodes).each do |from, to|
        add_connection(from:, to:)
      end
    end
  end
end
