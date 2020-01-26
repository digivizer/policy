# frozen_string_literal: true

require 'spec_helper'
require 'jwt'
require 'policy/builder'

describe ::Policy::Builder do
  let(:jwt_token) { JWT.encode(payload, ENV.fetch('JWT_SECRET'), ENV.fetch('JWT_ALGORITHM')) }
  let(:payload) { { "payload" => payload_body } }
  let(:payload_body) { { "some_id" => "abcd123456", "permissions" => permissions } }
  let(:permissions) { { "service" => { "resource" => resource_ids } } }
  let(:resource_ids) { ["9743jhksdf1208349", "03939484857543452345234523"] }
  let(:payload_details) { { "some_id" => "abcd123456" } }
  let(:policy_builder) { ::Policy::Builder.new(payload_details) }

  describe "#add_permissions!" do
    context "adds multiple permissions" do
      let(:expected_results) do
        {
          "payload" => {
            "some_id" => "abcd123456",
            "permissions" => {
              "service" => {
                "resource_ids" => ["asdlkfasjk", "123456789", "123456789"]
              },
              "another_service" => {
                "other_ids"=>["123aaslkjfdajkhlas"]
              }
            }
          }
        }
      end

      it "builds correct structure" do
        policy_builder
          .add_permissions!(:service, :resource_ids, ["asdlkfasjk", "123456789"])
          .add_permissions!(:service, :resource_ids, ["123456789"])
          .add_permissions!(:another_service, :other_ids, ["123aaslkjfdajkhlas"])
        expect(policy_builder.to_hash).to eq(expected_results)
      end
    end

    context "add nothing" do
      let(:expected_results) do
        {
          "payload" => {
            "some_id" => "abcd123456",
            "permissions" => {}
          }
        }
      end

      it "builds payload with empty permissions" do
        expect(policy_builder.to_hash).to eq(expected_results)
      end
    end
  end

  describe "#encode" do
    it "translates to jwt token" do
      policy_builder.add_permissions!(:service, :resource, resource_ids)
      expect(policy_builder.encode).to eq(jwt_token)
    end
  end
end
