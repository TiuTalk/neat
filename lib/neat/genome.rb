# frozen_string_literal: true

require_relative 'node'
require_relative 'connection'

module Neat
  class Genome
    attr_reader :nodes, :connections

    def initialize
      @nodes = Set.new
      @connections = Set.new
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
  end
end
