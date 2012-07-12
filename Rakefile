#!/usr/bin/env rake
require "bundler/gem_tasks"

task :test do
  Dir["test/*_test.rb"].each do |test|
    require_relative test
  end
end

task :default => 'test'
