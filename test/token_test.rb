require_relative 'setup'


describe GA::Token do
  describe '#valid?' do
    it 'returns true when given a valid token.' do
      stub = stub_request(:get, 'http://localhost/auth/my-valid-token/valid')
      stub.to_return body: Yajl.dump(valid: true)
      token = GA::Token.new 'my-valid-token'
      token.valid?.must_equal(true)
    end

    it 'returns false when givan an invalid token.' do
      stub = stub_request(:get, 'http://localhost/auth/my-invalid-token/valid')
      stub.to_return body: Yajl.dump(valid: false)
      token = GA::Token.new 'my-invalid-token'
      token.valid?.must_equal(false)
    end
  end

  describe '#can?' do
    it 'returns true when a user can do something.' do
      stub = stub_request(:get, 'http://localhost/auth/abc/access/def')
      stub.to_return body: Yajl.dump(allowed: true)
      token = GA::Token.new 'abc'
      token.can?('def').must_equal(true)
    end
    
    it 'returns false when a user cannot do something.' do
      stub = stub_request(:get, 'http://localhost/auth/123/access/456')
      stub.to_return body: Yajl.dump(allowed: false)
      token = GA::Token.new '123'
      token.can?('456').must_equal(false)
    end
  end
end
