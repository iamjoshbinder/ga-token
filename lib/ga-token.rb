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

  def expired?
    res = get "/auth/#{@token}/expired"
    res && res['expired']
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

    # TODO: use custom content-type that versions our data model.
    case res['content-type']
    when 'application/json'
      Yajl.load(res.body)
    else
      nil
    end
  end
end
