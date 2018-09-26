require 'twilio-ruby'
require 'phone_pb'
require 'hash_extensions'
require 'erb'
require 'twilio_call_detail_record_set'

class TwilioProvider
  # The bridge_code_url is a http url which contains TwiML code to handle the call bridging
  # The incoming_number is what displays on the a-leg of the join process.
  #  here, that means it is the number that the sales agent will see when
  #  answering for the first time.
  def initialize(params)
    params.requires! [:sid, :token, :incoming_number, :bridge_code_url]

    @client = Twilio::REST::Client.new params[:sid], params[:token]
    @incoming_number = params[:incoming_number]
    @bridge_code_url = params[:bridge_code_url]
    @bridged_call_timeout = params[:bridged_call_timeout]
  end

  def available_numbers
    hotel_dids = @client.incoming_phone_numbers.list.map do |incoming_number|
      hotel_did = Phone::HotelDid.new
      hotel_did.did = incoming_number.phone_number

      # Format: "Comfort Inn: Nashua, New Hampshire"
      description_format = /^([\w\s]+):\s+([\w\s]+),\s+([\w\s]+)$/i

      if (description_format =~ incoming_number.friendly_name)
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
  end

  def bridge_call(sales_agent, client, hotel, should_record = false)
    hotel = ERB::Util.url_encode(hotel)
    client = ERB::Util.url_encode(client)
    record = (record) ? "true" : "false"

    call = @client.calls.create(
      from: @incoming_number,
      to: sales_agent,
      url: "#{@bridge_code_url}?Hotel=#{hotel}&Client=#{client}&Record=#{record}",
      timeout: @bridged_call_timeout
    )
  end

  def get_b_leg(parent_sid)
    results = @client.calls.list(parent_call_sid: parent_sid)
    call = results.first

    return nil if call.nil?
    return nil if !/(queued|ringing|in-progress)/i.match(call.status).nil?
    return {
      sid: call.sid,
      answered: !/(completed)/i.match(call.status).nil?,
      failed: !/(failed|cancelled)/i.match(call.status).nil?,
      duration: call.duration.to_i
    }
  end

  def call_history(start_date, end_date)
    return get_incoming_calls(start_date, end_date)
  end

  private
  def get_incoming_calls(start_date, end_date)
    valid_statuses = %w(canceled completed failed busy no-answer)

    all_calls = []
    valid_statuses.each do |status|
      all_calls.concat(@client.calls.list({
        status: status, 
        start_time_after: start_date, 
        end_time_before: end_date +1
      }))
    end
    TwilioCallDetailRecordSet.new(@client, all_calls).parse_calls
  end
end

