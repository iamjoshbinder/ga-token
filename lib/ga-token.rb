require 'ga-token/version'
require 'yajl'
require 'excon'

module GA
end

class GA::Token
  APIError = Class.new(StandardError) 
  NoParserError = Class.new(StandardError)

  def self.acquire(assertion) 
    agent = Excon.new @host
    res = agent.post path: '/auth/identity', 
                     body: Yajl.dump(assertion: assertion), 
                     headers: { 'Content-Type' => 'application/json' }

    case res.status
    when 200..299
      body = Yajl.load(res.body) 
      new body['token'] 
    else
      nil
    end
  end
  
  def self.configure(&block)
    yield self
  end

  def self.host=(host)
    if host =~ %r(http(s?)://)
      @host = host
    else
      @host = "http://#{host}"
    end
  end

  def self.host
    @host
  end

  def owner
    return @owner if @owner
    res = get "/auth/identity/#{@token}"
    @owner = res['owner']
  end

  def value
    URI.decode_www_form_component(@token)
  end

  def expired?
    res = get "/auth/#{@token}/expired"
    return true if !res 
    res['expired']
  end

  def can?(privilege)
    privilege = URI.encode_www_form_component(privilege) 
    res = get "/auth/#{@token}/access/#{privilege}"
    res && res['allowed']
  end

private 
  def initialize(token)
    @token = URI.encode_www_form_component token
    @agent = Excon.new GA::Token.host
  end

  def process(res)
    case res.status
    when 200..299
      case res.headers['Content-Type']
      when 'application/json'
        Yajl.load(res.body)
      else
        raise NoParserError, "No parser for: '#{res.headers['Content-Type']}'."
      end
    when 404
      nil
    else
      raise APIError, "API responded with #{res.status}"
    end
  end

  %w(get put delete post).each do |verb|
    define_method(verb) do |path|
      res = @agent.send(verb, path: path)
      process(res) 
    end
  end
end
