require 'policy'

module Rack
  class Authorization
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["HTTP_AUTHORIZATION"]
        begin
          jwt_token = env.fetch("HTTP_AUTHORIZATION", '').slice(7..-1)
          policy = ::Policy.for_jwt(jwt_token)
          @app.call(env.merge('policy' => policy))
        rescue JWT::DecodeError => e
          [401, {}, []]
        end
      else
        [401, {}, []]
      end
    end
  end
end
