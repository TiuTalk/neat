# frozen_string_literal: true

module Neat
  class Crossover
    def initialize(genome_a, genome_b)
      # TODO: Check fitness?
      @genome_a = genome_a
      @genome_b = genome_b
    end

    def self.call(genome_a, genome_b)
      new(genome_a, genome_b).call
    end

    def call
      @child = @genome_a.neat.create_genome(connected: false)

      add_matching_genes
      add_disjoint_genes
      add_excess_genes

      @child
    end

    private

    def add_matching_genes
      distance.matching_genes.each do |conn_a, conn_b|
        # TODO: Check for disabled connection
        add_connection([conn_a, conn_b].sample)
      end
    end

    def add_disjoint_genes
      distance.disjoint_a_genes.each { add_connection(_1) }
    end

    def add_excess_genes
      distance.excess_a_genes.each { add_connection(_1) }
    end

    def add_node(node)
      @child.add_node(id: node.id, type: node.type)
    end

    def add_connection(conn, **args)
      # Add the nodes
      args[:from] = add_node(conn.from)
      args[:to] = add_node(conn.to)
      args[:weight] ||= conn.weight

      # Add the connection
      @child.add_connection(**args)
    end

    def distance
      @distance ||= Distance.new(@genome_a, @genome_b)
    end
  end
end
