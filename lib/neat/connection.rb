# frozen_string_literal: true

require_relative 'node'

module Neat
  class Connection
    attr_reader :id, :from, :to, :enabled
    attr_accessor :weight

    def initialize(id:, from:, to:, weight: nil, enabled: true)
      raise ArgumentError, 'from must be a Node' unless from.is_a?(Node)
      raise ArgumentError, 'to must be a Node' unless to.is_a?(Node)

      @id = id
      @from = from
      @to = to
      @weight = weight || random_weight
      @enabled = enabled
    end

    def enabled?
      @enabled == true
    end

    def disabled?
      @enabled == false
    end

    def to_s
      "Connection##{id} (#{from.id} -> #{to.id})"
    end

    def ==(other)
      other.is_a?(self.class) && other.from == from && other.to == to
    end
    alias eql? ==

    def hash
      [from, to].hash
    end

    private

    def random_weight
      rand(::Neat.config.connection_weight_range)
    end
  end
end
