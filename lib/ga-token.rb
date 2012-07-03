require "ga-token/version"
require "dash"

module GA
  class Token
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
      @host  = GA::Token.host.dup
      p @host
      @agent = Dash::Agent.new(@host)  
    end

    def valid?
      res = @agent.get "/auth/#{@token}/valid"
      res['valid']
    end

    def can?(privilege)
      privilege = URI.encode_www_form_component(privilege) 
      res = @agent.get "/auth/#{@token}/access/#{privilege}"
      res['allowed']
    end
  end
end
