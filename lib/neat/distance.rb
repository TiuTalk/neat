# frozen_string_literal: true

module Neat
  class Distance
    def initialize(genome_a, genome_b)
      raise ArgumentError, 'genome_a must be a Genome' unless genome_a.is_a?(Genome)
      raise ArgumentError, 'genome_b must be a Genome' unless genome_b.is_a?(Genome)

      @genome_a = genome_a
      @genome_b = genome_b
    end

    def self.call(genome_a, genome_b)
      new(genome_a, genome_b).call
    end

    def call
      distance = (c1 * excess_genes_count) / genes_count
      distance += (c2 * disjoint_genes_count) / genes_count
      distance += c3 * average_weight_difference
      distance
    end

    def matching_genes
      @matching_genes ||= @genome_a.connections.filter_map do |conn_a|
        conn_b = @genome_b.connections.find { _1 == conn_a }

        [conn_a, conn_b] if conn_b
      end
    end

    %i[disjoint excess].each do |type|
      define_method(:"#{type}_genes") { send(:"#{type}_a_genes") + send(:"#{type}_b_genes") }
      define_method(:"#{type}_a_genes") { send(:"#{type}_genes_between", @genome_a, @genome_b) }
      define_method(:"#{type}_b_genes") { send(:"#{type}_genes_between", @genome_b, @genome_a) }
      define_method(:"#{type}_genes_count") { send(:"#{type}_genes").count }
    end

    private

    # Returns the genes that are in one but not in other (lower than max ID)
    def disjoint_genes_between(one, other)
      other_ids = other.connections.map(&:id)

      one.connections.reject do |conn|
        other_ids.include?(conn.id) || conn.id > other_ids.max
      end
    end

    # Returns the genes that are in one but not in other (higher than max ID)
    def excess_genes_between(one, other)
      other_ids = other.connections.map(&:id)

      one.connections.reject do |conn|
        other_ids.include?(conn.id) || conn.id < other_ids.max
      end
    end

    def average_weight_difference
      matching_genes.sum do |conn_a, conn_b|
        (conn_a.weight - conn_b.weight).abs
      end
    end

    def genes_count
      @genes_count ||= [@genome_a.connections.size, @genome_b.connections.size].max
    end

    extend Forwardable
    def_delegator :'Neat.config', :distance_excess_genes_coefficient, :c1
    def_delegator :'Neat.config', :distance_disjoint_genes_coefficient, :c2
    def_delegator :'Neat.config', :distance_weight_difference_coefficient, :c3
  end
end
