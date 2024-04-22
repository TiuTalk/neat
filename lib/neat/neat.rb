# frozen_string_literal: true

require_relative 'genome'

module Neat
  class Neat
    attr_reader :inputs, :outputs, :bias

    def initialize(inputs:, outputs:, bias: true)
      @inputs = inputs
      @outputs = outputs
      @bias = bias
    end

    def create_genome(connected: true)
      Genome.new(inputs:, outputs:, bias:, connected:)
    end
  end
end
