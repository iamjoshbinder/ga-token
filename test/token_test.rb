require_relative 'setup'

describe GA::Token do
  let(:headers) { {'Content-Type'  => 'application/json' } }
  
  describe '#expired?' do
    it 'returns true when a token has expired.' do
      stub = stub_request(:get, 'http://localhost/auth/my-invalid-token/expired')
      stub.to_return body: Yajl.dump(expired: true), headers: headers
      token = GA::Token.new 'my-invalid-token'
      token.expired?.must_equal(true)
    end

    it 'returns true when the token does not exist.' do
      stub = stub_request(:get, 'http://localhost/auth/dontexist/expired')
      stub.to_return status: "404"
      token = GA::Token.new 'dontexist'
      token.expired?.must_equal(true)
    end

    it 'returns false when a token has not expired.' do
      stub = stub_request(:get, 'http://localhost/auth/my-valid-token/expired')
      stub.to_return body: Yajl.dump(expired: false), headers: headers
      token = GA::Token.new 'my-valid-token'
      token.expired?.must_equal(false)
    end
  end

  describe '#can?' do
    it 'returns true when a user can do something.' do
      stub = stub_request(:get, 'http://localhost/auth/my-token/access/email')
      stub.to_return body: Yajl.dump(allowed: true), headers: headers
      token = GA::Token.new 'my-token'
      token.can?('email').must_equal(true)
    end
    
    it 'returns false when a user cannot do something.' do
      stub = stub_request(:get, 'http://localhost/auth/my-token/access/run-job')
      stub.to_return body: Yajl.dump(allowed: false), headers: headers
      token = GA::Token.new 'my-token'
      token.can?('run-job').must_equal(false)
    end
  end
end
