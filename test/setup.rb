require 'bundler/setup'
Bundler.setup :default, :test

require 'yajl'
require 'ga-token'
require 'minitest/spec'
require 'minitest/autorun'
require 'fakeweb'

GA::Token.configure do |c|
  c.host = 'generalassemb.ly'
end
