require 'bundler/setup'
Bundler.setup :default, :test

require 'yajl'
require 'ga-token'
require 'minitest/spec'
require 'minitest/autorun'
require 'webmock/minitest'

GA::Token.configure do |c|
  c.host = 'localhost'
end
