# frozen_string_literal: true

module Neat
  class Configuration
    def self.config(name, default)
      attr_writer name

      define_method(name) do
        instance_variable_defined?(:"@#{name}") ? instance_variable_get(:"@#{name}") : default
      end
    end

    # Network parameters
    config :connection_weight_range, (-1.0..1.0)

    # Activation function
    config :activation_function, ->(value) { 1.0 / (1.0 + Math.exp(-value)) }

    # Mutation parameters
    config :mutation_add_node_chance, 0.03
    config :mutation_add_connection_chance, 0.05
    config :mutation_mutate_weights_chance, 0.8
    config :mutation_randomize_weight_chance, 0.1
    config :mutation_perturb_weight_range, (-0.2..0.2)

    # Crossover parameters
    config :crossover_inherit_disabled_gene_chance, 0.75

    # Distance parameters
    config :distance_excess_genes_coefficient, 1.0
    config :distance_disjoint_genes_coefficient, 1.0
    config :distance_weight_difference_coefficient, 0.4
    config :species_compatibility_threshold, 3.0

    # Evolution parameters
    config :target_species, 5
    config :survival_threshold, 0.2
  end
end
