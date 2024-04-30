# frozen_string_literal: true

module Neat
  module WeightedRandom
    def choose(list, method)
      total = list.sum(&method)
      threshold = total * rand

      list.shuffle.each do |item|
        threshold -= item.public_send(method)

        return item if threshold <= 0
      end
    end
  end
end
