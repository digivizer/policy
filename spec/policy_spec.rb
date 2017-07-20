# frozen_string_literal: true

require 'spec_helper'
require 'jwt'
require 'policy'

describe ::Policy do
  let(:jwt_token) { JWT.encode(payload, ENV.fetch('HMAC_SECRET'), ENV.fetch('JWT_ALGORITHM')) }
  let(:payload) { { "payload" => payload_body } }
  let(:payload_body) { { "some_id" => "abcd123456", "permissions" => permissions } }
  let(:permissions) { { "service" => { "resource" => ["abcdefghjiklmnopqrstuv"] } } }
  let(:policy) { ::Policy.for_jwt(jwt_token) }
  let(:resource_id) { "abcdefghjiklmnopqrstuv" }

  describe "#allowed?" do
    context "with valid account id" do
      it "is allowed" do
        expect(policy.allowed?(:service, :resource, resource_id)).to be true
      end

      context "with empty payload" do
        let(:payload) { {} }

        it "is not allowed" do
          expect(policy.allowed?(:service, :resource, resource_id)).to be false
        end
      end

      context "with no permissions for a service" do
        let(:permissions) { { :service => {} } }

        it "is not allowed" do
          expect(policy.allowed?(:service, :resource, resource_id)).to be false
        end
      end
    end

    context "with invalid account id" do
      let(:resource_id) { "boo-urns" }

      it "is not allowed" do
        expect(policy.allowed?(:service, :resource, resource_id)).to be false
      end
    end
  end
end
