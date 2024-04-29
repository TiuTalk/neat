# frozen_string_literal: true

module Neat
  class Crossover
    def initialize(genome_a, genome_b)
      raise ArgumentError, 'genome_a must be a Genome' unless genome_a.is_a?(Genome)
      raise ArgumentError, 'genome_b must be a Genome' unless genome_b.is_a?(Genome)

      @genome_b, @genome_a = [genome_a, genome_b].sort_by(&:fitness)
    end

    def crossover
      @child = @genome_a.neat.create_genome(connected: false)

      add_matching_genes
      add_disjoint_genes
      add_excess_genes

      @child
    end

    private

    extend Forwardable
    def_delegators :'Neat.config', :crossover_inherit_disabled_gene_chance

    def add_matching_genes
      distance.matching_genes.each do |conn_a, conn_b|
        disabled = (conn_a.disabled? || conn_b.disabled?) && rand < crossover_inherit_disabled_gene_chance

        add_connection([conn_a, conn_b].sample, enabled: !disabled)
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

      # Add the connection
      args[:weight] ||= conn.weight
      args[:enabled] = conn.enabled? unless args.key?(:enabled)

      @child.add_connection(**args)
    end

    def distance
      @distance ||= Distance.new(@genome_a, @genome_b)
    end
  end
end
