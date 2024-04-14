# frozen_string_literal: true

module Neat
  class Configuration
    def self.config(name, default)
      attr_writer name

      define_method(name) do
        instance_variable_defined?(:"@#{name}") ? instance_variable_get(:"@#{name}") : default
      end
    end
  end
end
