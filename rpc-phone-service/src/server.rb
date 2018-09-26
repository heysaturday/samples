base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.join(base_dir, 'lib'))
$LOAD_PATH.unshift(File.join(base_dir, 'src'))

require 'grpc'
require 'phone_service'
require 'twilio'
require 'voipms'
require 'sequel'
require 'common'

def main(base_dir)
  config = {
    twilio: {
      sid: ENV['TWILIO_SID'],
      token: ENV['TWILIO_TOKEN'],
      bridge_code_url: ENV['TWILIO_CALL_BRIDGE_URL'],
      incoming_number: ENV['INCOMING_NUMBER'],
      bridged_call_timeout: ENV['BRIDGED_CALL_TIMEOUT'] || 8 # in seconds
    },
    voipms: {
      user: ENV['VOIPMS_USER'],
      password: ENV['VOIPMS_PASS']
    }
  }

  # Build phone service
  db = Sequel.connect(ENV['DB_CONNECTION'])
  twilio = TwilioProvider.new(config[:twilio])
  voipms = VoipMsProvider.new(config[:voipms])
  phone_service = PhoneService.new(twilio, voipms, db)

  # Setup Mutual Authentication
  certs = {
    ca: File.read(File.join(base_dir, 'certs/NextHotelSolutions_CA.crt')),
    cert_chain:  File.read(File.join(base_dir, 'certs/service.crt')),
    private_key: File.read(File.join(base_dir, 'certs/service.key')),
  } 
  credentials = GRPC::Core::ServerCredentials.new(certs[:ca], [certs], true) 

  # Host phone service in rpc server
  rpc = GRPC::RpcServer.new
  rpc.add_http2_port("0.0.0.0:#{ENV['PORT']}", credentials)
  rpc.handle(phone_service)
  rpc.run_till_terminated
end

main(base_dir)
