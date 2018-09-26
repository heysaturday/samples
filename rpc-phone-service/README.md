# The Phone Service
This service exposes several RPCs which allow clients to manipulate the Next
Hotel Solutions assorted phone services, whether that is Voip.Ms or Twilio.

# Installation
bundle install --binstubs

# Running The Project
Make sure that you have the following environment variables set
  
TWILIO_SID=
TWILIO_TOKEN=
TWILIO_TEST_SID=AC0a76e5bc4bbff297d07d1bd0d072b870
TWILIO_TEST_TOKEN=94032e77a1418fe019f8f910d7b7ce24
VOIPMS_USER=
VOIPMS_PASS=
INCOMING_NUMBER="+1 865-257-9555"
TWILIO_CALL_BRIDGE_URL="https://handler.twilio.com/twiml/EHf75543758cc3531672230047ebd11e4a"
DB_CONNECTION="postgres://<username>:<password>@db.nexthotelsales.com/phone_service"
  
ruby src/server.rb

# Development
## Database Migrations
put your migrations in the `/migrations` folder  
run `bin/sequel -m migrations $DB_CONNECTION`  

## Running rspec
run `bin/rspec --format doc`

## Re-compiling GRPC service spec
run `grpc_tools_ruby_protoc --ruby_out=lib --grpc_out=lib phone.proto`