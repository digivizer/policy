# frozen_string_literal: true
require_relative "policy/version"

require 'jwt'

class Policy

  attr_accessor :payload

  def initialize(payload={})
    @payload = payload
  end

  # Creates a new instance of this class specifically for jwt tokens
  #
  # @return [Policy] self
  #
  def self.for_jwt(jwt_token)
    decoded_payload = decode_jwt(jwt_token)
    self.new(decoded_payload)
  end

  # Fetches permissions details for a service resouce
  # and checks if it includes a specific identity
  #
  # @param service [String, Symbol] service to check permission
  # @param resource [String, Symbol] resource to check permission
  # @param identities [String] identity to check permission
  #
  # @return [Bool]
  #
  def allowed?(service, resource, identity)
    permissions
      .fetch(service.to_s, {})
      .fetch(resource.to_s, [])
      .include?(identity)
  end

  private

  def permissions
    payload.fetch("payload", {}).fetch("permissions", {})
  end

  # Decode JWT token into payload details and permissions
  #
  # JWT token contains information about algorithm and token type but
  # in the decode method we are only interested in the payload permissions information
  #
  #
  # @return [String] JWT token
  #
  def self.decode_jwt(jwt_token)
    JWT.decode(
      jwt_token,
      ENV.fetch('HMAC_SECRET'),
      true,
      { :algorithm => ENV.fetch('JWT_ALGORITHM') }
    ).first
  end

end
