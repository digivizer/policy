require 'spec_helper'
require 'policy'
require 'policy/builder'

describe "JWT token" do

  let(:payload) { { "payload" => payload_body } }
  let(:payload_body) { { "some_id" => "abcd123456", "permissions" => permissions } }
  let(:permissions) { { "service" => { "resource" => ["123456", "986758676abcdefg"] } } }
  let(:resource_ids) { ["123456", "986758676abcdefg"] }
  let(:payload_details) { { "some_id" => "abcd123456" } }
  let(:policy_builder) { ::Policy::Builder }
  let(:policy) { ::Policy }

  let(:jwt_token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXlsb2FkIjp7InNvbWVfaWQiOiJhYmNkMTIzNDU2IiwicGVybWlzc2lvbnMiOnsic2VydmljZSI6eyJyZXNvdXJjZSI6WyIxMjM0NTYiLCI5ODY3NTg2NzZhYmNkZWZnIl19fX19.yyYf9zmQUiF8wL4zo5nADWwntjmz1CyG8JKgecFWpE4' }

  let(:encoded_token) { policy_builder.new(payload_details).add_permissions!(:service, :resource, resource_ids).encode }

  it "encodes correctly" do
    puts encoded_token
    expect(encoded_token).to eq(jwt_token)
  end

  it 'decodes correctly' do
    expect(policy.for_jwt(encoded_token).payload).to eq(payload)
  end
end
