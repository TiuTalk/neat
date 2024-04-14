# frozen_string_literal: true

module Neat
  class Node
    TYPES = %i[input output bias hidden].freeze

    attr_reader :id, :type

    def initialize(id:, type: :hidden)
      raise ArgumentError, "Invalid type: #{type}" unless TYPES.include?(type)

      @id = id
      @type = type
    end

    def to_s
      "Node##{id} (#{type})"
    end

    def ==(other)
      other.is_a?(self.class) && other.id == id
    end
    alias eql? ==

    def hash
      id.hash
    end

    # NOTE: Define methods like input? output? bias? and hidden?
    TYPES.each do |type|
      define_method(:"#{type}?") { @type == type }
    end
  end
end
