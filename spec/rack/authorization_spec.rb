require 'spec_helper'
require 'jwt'
require 'rack/authorization'

describe ::Rack::Authorization do
  let(:app) { -> (env) { env } }
  let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" } }


  context 'valid jwt_token' do
    let(:payload) { { "payload" => payload_body } }
    let(:payload_body) { { "some_id" => "abcd123456", "permissions" => permissions } }
    let(:permissions) { { "service" => { "resource" => ["abcdefghjiklmnopqrstuv"] } } }
    let(:jwt_token) { JWT.encode(payload, ENV.fetch('HMAC_SECRET'), ENV.fetch('JWT_ALGORITHM')) }

    it "passes the policy value to @app.call(env)" do
      expect(described_class.new(app).call(env)['policy'].payload).to eq(payload)
    end
  end

  context "invalid jwt_token" do
    let(:jwt_token) { 'ASDFSAdvasdfasDFASDFasdfsadfasdfasdf' }
    it "is unauthenticated response" do
      expect(described_class.new(app).call(env)).to eq([401, {}, []])
    end
  end

  context "no HTTP_AUTHORIZATION header" do
    it "is unauthenticated response" do
      expect(described_class.new(app).call({})).to eq([401, {}, []])
    end
  end
end
