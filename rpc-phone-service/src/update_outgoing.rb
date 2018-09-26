base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.join(base_dir, 'lib'))
$LOAD_PATH.unshift(File.join(base_dir, 'src'))

require 'grpc'
require 'phone_service'
require 'twilio'
require 'voipms'
require 'sequel'
require 'common'
require 'time_difference'

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
  puts "Configuring Database Connection"
  db = Sequel.connect(ENV['DB_CONNECTION'])

  puts "Configuring Twilio Connection"
  twilio = TwilioProvider.new(config[:twilio])

  puts "Configuring VoipMs Connection"
  voipms = VoipMsProvider.new(config[:voipms])

  puts "Starting Phone Service Code ..."
  phone_service = PhoneService.new(twilio, voipms, db)

  puts "Updating Outgoing Calls now.."
  start_time = Time.now
  phone_service.update_in_progress_calls(nil, nil)

  puts "Finished. Call updating took #{TimeDifference.between(start_time, Time.now).in_minutes} mins"
end

main(base_dir)
