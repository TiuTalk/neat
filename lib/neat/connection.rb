# frozen_string_literal: true

require_relative 'node'

module Neat
  class Connection
    attr_reader :id, :from, :to, :weight, :enabled

    def initialize(id:, from:, to:, weight: nil, enabled: true)
      raise ArgumentError, 'from must be a Node' unless from.is_a?(Node)
      raise ArgumentError, 'to must be a Node' unless to.is_a?(Node)

      @id = id
      @from = from
      @to = to
      @weight = weight || random_weight
      @enabled = enabled
    end

    def to_s
      "Connection##{id} (#{from.id} -> #{to.id})"
    end

    def ==(other)
      other.is_a?(self.class) && other.from == from && other.to == to
    end
    alias eql? ==

    private

    def random_weight
      rand(::Neat.config.connection_weight_range)
    end
  end
end
