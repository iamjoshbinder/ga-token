require "ga-token/version"
require "net/http"

module GA
end

class GA::Token
  def self.host=(host)
    @host = host
  end

  def self.host
    @host
  end

  def self.configure(&block)
    yield(self) 
  end

  def initialize(token)
    @token = URI.encode_www_form_component(token)
    @host  = GA::Token.host
    @agent = Net::HTTP.new(@host)
  end

  def valid?
    res = get "/auth/#{@token}/valid"
    res['valid']
  end

  def can?(privilege)
    privilege = URI.encode_www_form_component(privilege) 
    res = get "/auth/#{@token}/access/#{privilege}"
    res['allowed']
  end

private 
  def get(path)
    req = Net::HTTP::Get.new(path)
    @agent.start
    res = @agent.request(req)
    @agent.finish
    Yajl.load(res.body)
  end
end
