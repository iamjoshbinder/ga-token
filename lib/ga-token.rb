require "ga-token/version"
require "net/http"

module GA
end

class GA::Token
  APIError = Class.new(StandardError) 
  NoParserError = Class.new(StandardError)
  
  def self.host=(host)
    @host = host
  end

  def self.host
    @host
  end

  def self.configure(&block)
    yield(self) 
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
    @token = URI.encode_www_form_component(token)
    @host  = GA::Token.host
    @agent = Net::HTTP.new(@host)
  end

  def get(path)
    req = Net::HTTP::Get.new(path)
    @agent.start
    res = @agent.request(req)
    @agent.finish

    case res
    when Net::HTTPOK
      case res['content-type']
      when 'application/json'
        Yajl.load(res.body)
      else
        raise NoParserError, "No parser for: '#{res['content-type']}'." 
      end
    when Net::HTTPNotFound
      nil
    else
      raise APIError, "API responded with #{res.code}"
    end
  end
end
