require 'httparty'
require 'hash_extensions'
require 'voipms_call_detail_record_set'
require 'phone_pb'

class VoipMsProvider
  include HTTParty
  base_uri 'https://voipmsproxy.nexthotelsales.com/api/v1/rest.php'
  # uncomment to debug
  # http_proxy 'localhost', '8080'

  def initialize(params)
    params.requires! [:user, :password]

    @options = {
      # verify: false, # uncomment to debug
      headers: {
        'Accept' => 'application/json'
      },
      query: {
        api_username: params[:user],
        api_password: params[:password]
      }
    }
  end

  def available_numbers
    hotel_dids = get('getDIDsInfo')['dids'].map do |incoming_number|
      hotel_did = Phone::HotelDid.new
      hotel_did.did = incoming_number['did']

      # Format: "Comfort Inn: Nashua, New Hampshire"
      description_format = /^([\w\s]+):\s+([\w\s]+),\s+([\w\s]+)$/i

      if (description_format =~ incoming_number['note'])
        hotel_did.franchise = $1
        hotel_did.city = $2
        hotel_did.state = $3
      else
        hotel_did.franchise = 'Unknown Franchise' 
        hotel_did.city = 'Unknown City'
        hotel_did.state = 'Unknown State'
      end
      hotel_did
    end

    hotel_dids.select {|hotel| /^\d+$/.match(hotel.did)}
  rescue
    []
  end

  def call_history(start_date, end_date)
    params = {
      date_from: start_date.to_s,
      date_to: end_date.to_s,
      timezone: -5,
      account: "all",
      answered: 1,
      noanswer: 1,
      busy: 1,
      failed: 1
    }

    resp = get("getCDR", params)
    VoipMsCallDetailRecordSet.new(resp).parse_records
  end

  private
  def get(method, params={})
    params[:method] = method
    options = @options.merge({query: @options[:query].merge(params)})

    resp = self.class.get('', options)

    if (resp.code.to_i == 200)
      JSON.parse(resp.body) 
    else
      raise Exception.new("Unknown Voipms response: #{resp.code} #{resp.body}")
    end
  end
end
