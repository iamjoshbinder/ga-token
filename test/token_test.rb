require_relative 'setup'

describe GA::Token do

  describe '#valid?' do
    it 'returns true when given a valid token.' do
      FakeWeb.register_uri :get, %r{/auth/[\w,-]+/valid}, body: Yajl.dump(valid: true) 
      token = GA::Token.new 'my-valid-token'
      token.valid?.must_equal(true)
    end

    it 'returns false when givan an invalid token.' do
      FakeWeb.register_uri :get, %r{/auth/[\w,-]+/valid}, body: Yajl.dump(valid: false)
      token = GA::Token.new 'my-invalid-token'
      token.valid?.must_equal(false)
    end
  end

  describe '#can?' do
    it 'returns true when a user can do something.' do
      FakeWeb.register_uri :get, %r{/auth/[\w,-]+/access/[\w,-]+}, Yajl.dump(allowed: true)
      token = GA::Token.new 'i-can-disco-dance'
      token.can?('disco-dance').must_equal(true)
    end
    
    it "returns false when a user can't do something" do
      FakeWeb.register_uri :get, '/auth/i-cant-dance/access/disco-dance', Yajl.dump(allowed: false)
      token = Ga::Token.new 'i-cant-disco-dance'
      token.can?('disco-dance').must_equal(false)
    end
  end
end
