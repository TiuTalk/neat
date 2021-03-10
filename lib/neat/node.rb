require 'securerandom'

module Neat
  class Node
    TYPES = %i[input bias hidden output].freeze

    attr_reader :id, :type

    def initialize(id: SecureRandom.hex(4), type: :hidden)
      @id = id
      @type = type
    end

    TYPES.each do |type|
      define_method(:"#{type}?") { @type == type }
    end

    def to_s
      "#{@type.capitalize}##{@id}"
    end
  end
end
