# frozen_string_literal: true

require_relative 'genome'
require_relative 'species'

module Neat
  class Neat
    attr_reader :inputs, :outputs, :bias, :nodes, :connections

    def initialize(inputs:, outputs:, bias: true)
      @inputs = inputs
      @outputs = outputs
      @bias = bias

      @nodes = Set.new
      @connections = Set.new
    end

    def add_node(**args)
      args[:id] ||= @nodes.count + 1

      node = Node.new(**args)

      if @nodes.add?(node)
        node
      else
        @nodes.find { _1 == node }.clone
      end
    end

    def add_connection(**args)
      args[:id] ||= @connections.count + 1

      conn = Connection.new(**args)

      if @connections.add?(conn)
        conn
      else
        @connections.find { _1 == conn }.clone
      end
    end

    def create_genome(connected: true)
      Genome.new(neat: self, connected:)
    end
  end
end
