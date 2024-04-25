# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'pry'

gem 'bundler-audit'

gem 'rspec'
gem 'rspec_junit_formatter'

# Code Coverage
gem 'simplecov', require: false
gem 'simplecov-lcov', require: false

gem 'rubocop'
%i[rspec performance thread_safety].each do |extension|
  gem "rubocop-#{extension}"
end
