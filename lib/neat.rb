# frozen_string_literal: true

require_relative 'neat/configuration'
require_relative 'neat/genome'
require_relative 'neat/evaluator'
require_relative 'neat/version'

module Neat
  class Error < StandardError; end

  def self.config
    @config ||= Configuration.new # rubocop:disable ThreadSafety/InstanceVariableInClassMethod
  end

  def self.configure
    yield(config)
  end
end
