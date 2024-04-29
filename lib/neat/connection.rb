# frozen_string_literal: true

require_relative 'node'

module Neat
  class Connection
    attr_reader :id, :from, :to
    attr_accessor :weight, :enabled

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
      "Connection##{id} (#{from.id} #{enabled? ? '=>' : '->'} #{to.id}) #{weight}"
    end

    def ==(other)
      other.is_a?(self.class) && other.from == from && other.to == to
    end
    alias eql? ==

    def hash
      [from, to].hash
    end

    def clone
      Connection.new(id:, from:, to:)
    end

    def randomize_weight
      @weight = random_weight
    end

    def perturb_weight
      amount = weight * rand(mutation_perturb_weight_range)

      @weight += amount
      @weight = @weight.clamp(connection_weight_range)
    end

    private

    extend Forwardable
    def_delegators :'Neat.config', :connection_weight_range, :mutation_perturb_weight_range,
      :mutation_randomize_weight_chance

    def random_weight
      rand(connection_weight_range)
    end
  end
end
