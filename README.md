# Policy

The Policy gem is a builder and interpreter for authorization payloads between Different services

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'policy', :git => 'https://github.com/digivizer/policy.git'
```

And then execute:

    $ bundle install

## Using the middleware for rack app
in the `config.ru` file of your rack app add:
```
require 'rack/authorization'

use Rack::Authorization

run YourApp.app
```

Now that the middleware has been added to `YourApp` it will check if each request to your app has a valid `JWT` token and it will decode it

This decoded coded jwt token can now be accessed in your app by calling the `request.env['policy']` variable.

for example inside a [roda](https://github.com/jeremyevans/roda) app it would look something like
```
class YourApp < Roda
  r.get "hello" do

    policy = request.env['policy']

    if policy.allowed?(:speak_service, :greeting, "MyId1234")
      @greeting = 'Hello, how are you'
    else
      @greeting = 'Go away, your not allowed to speak!'
    end
  end
end
```

## Usage

Setup environment variables
```
ENV['HMAC_SECRET'] = 'hmac_secret'
ENV['JWT_ALGORITHM'] = 'HS256'
```

Creating and new JWT token

```
require 'policy/builder'

payload_details = { some_id: "abcdefghijklmnopqrstuv" }

policy = Policy::Builder.new(payload_details)
=> #<Policy::Builder:0x007f90de313bb8 @payload_details={:some_id=>"abcdefghijklmnopqrstuv"}, @permissions={}>

policy.add_permissions!(:service, :resource, [1, 2, 3, 4])
=> #<Policy::Builder:0x007f90de313bb8 @payload_details={:some_id=>"abcdefghijklmnopqrstuv"}, @permissions={"service"=>{"resource"=>[1, 2, 3, 4]}}>

jwt_token = policy.encode
=> "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXlsb2FkIjp7InNvbWVfaWQiOiJhYmNkZWZnaGlqa2xtbm9wcXJzdHV2IiwicGVybWlzc2lvbnMiOnsic2VydmljZSI6eyJyZXNvdXJjZSI6WzEsMiwzLDRdfX19fQ.bawJReLI0cTLg0W8oCrsI3t9q4_P6kcp4tpVO9ULURw"

```

Reading a JWT token

```
require 'policy'

decoded_policy = Policy.for_jwt(jwt_token)
=> #<Policy:0x007f90de2a91a0 @payload={"payload"=>{"some_id"=>"abcdefghijklmnopqrstuv", "permissions"=>{"service"=>{"resource"=>[1, 2, 3, 4]}}}}>

decoded_policy.allowed?(:service, :resource, 1)
=> true

decoded_policy.allowed?(:service, :resource, 5)
=> false

decoded_policy.allowed?(:service, :other_resource, 5)
=> false
```

