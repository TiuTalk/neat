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
    config :connection_weight_range, (-2.0..2.0)

    # Activation function
    config :activation_function, ->(value) { 1.0 / (1.0 + Math.exp(-value)) }

    # Mutation parameters
    config :mutation_add_node_probability, 0.03
    config :mutation_add_connection_probability, 0.05
    config :mutation_add_connection_tries, 10
  end
end
