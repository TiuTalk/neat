# frozen_string_literal: true

require_relative 'neat/neat'
require_relative 'neat/configuration'
require_relative 'neat/version'

module Neat
  class Error < StandardError; end

  def self.config
    @config ||= Configuration.new # rubocop:disable ThreadSafety/InstanceVariableInClassMethod
  end

  # :nocov:
  def self.configure
    yield(config)
  end
  # :nocov:
end
