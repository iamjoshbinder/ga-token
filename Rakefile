#!/usr/bin/env rake
require "bundler/gem_tasks"

namespace :test do
  task :run do
    system "bundle", "exec", "ruby", "-Ilib", "test/*_test.rb" 
  end
end

task :default => 'test:run'
