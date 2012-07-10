require 'ga-token/version'
require 'yajl'
require 'excon'

module GA
end

class GA::Token
  def self.acquire(assertion) 
    agent = HTTPAgent.new @host
    body = Yajl.dump(assertion: assertion)
    headers = { 'Content-Type' => 'application/json' }
    res = agent.post '/auth/identity', body: body, headers: headers
    body = Yajl.load(res.body) 
    new body['token']
  end
  
  def self.configure(&block)
    yield self
  end

  def self.host=(host)
    @host = host
  end

  def self.host
    @host
  end

  def owner
    return @owner if @owner
    res = @agent.get "/auth/identity/#{@token}"
    @owner = res['owner']
  end

  def value
    URI.decode_www_form_component(@token)
  end

  def expired?
    res = @agent.get "/auth/#{@token}/expired"
    return true if !res 
    res['expired']
  end

  def can?(privilege)
    privilege = URI.encode_www_form_component(privilege) 
    res = @agent.get "/auth/#{@token}/access/#{privilege}"
    res && res['allowed']
  end

private 
  def initialize(token)
    @token = URI.encode_www_form_component token
    @agent = HTTPAgent.new GA::Token.host
  end
end

class GA::Token::HTTPAgent
  APIError = Class.new(StandardError)

  %w(get put delete post).each do |verb|
    define_method(verb) do |path, options = {}|
      res = @agent.send verb, options.merge(path: path)
      process(res)
    end
  end

private 
  def initialize(domain)
    @agent = Excon.new normalize(domain)
  end
  
  def normalize(domain)
    if domain =~ %r(^http(s?)://)
      domain
    else
      "http://#{domain}"
    end
  end

  def process(res)
    case res.status
    when 200..299
      Yajl.load(res.body)
    when 404
      nil
    else
      raise APIError, "API responded with #{res.status}"
    end
  end
end
