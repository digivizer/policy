# frozen_string_literal: true

require 'jwt'

class Policy

  class Builder

    attr_accessor :payload_details, :permissions

    def initialize(payload_details)
      @payload_details = payload_details.to_hash
      @permissions = {}
    end

    # Adds permission to the builder
    # a permission requires a service such as :paid or "organic"
    # also requires a resource such as :accounts or "campaigns"
    #
    # service and resources are used as keys in the permission hash
    #
    # identities is a list of allowed resources for the
    # user provided in creation of an instance of this class
    #
    # @param service [String, Symbol] key name for allowed resource
    # @param resource [String, Symbol] key name for allowed identities
    # @param identities [Array] allowed identities
    #
    # @return [PolicyBuilder] self
    #
    def add_permissions!(service, resource, identities)
      permissions[service.to_s] ||= {}
      permissions[service.to_s][resource.to_s] ||= []
      permissions[service.to_s][resource.to_s].concat(identities)
      self
    end

    # Convert all the permission details for a payload to a hash
    # This hash can be used as a payload for jwt token encoding
    #
    # @return [Hash] payload hash for jwt
    #
    def to_hash
      { "payload" => payload_details.merge({"permissions" => permissions}) }
    end

    # Convert payload_details and their permissions into a jwt token
    #
    # @return [String] JWT token
    #
    def encode
      JWT.encode(
        to_hash,
        ENV.fetch('HMAC_SECRET'),
        ENV.fetch('JWT_ALGORITHM')
      )
    end

  end

end
