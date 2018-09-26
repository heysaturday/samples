require 'common'
require 'phone_pb'
require 'phone_number'

class TwilioCallDetailRecordSet

  def initialize(twilio_client, calls)
    @client = twilio_client
    @calls = calls
  end

  def parse_calls
    inbound_calls = directional_inbound_records
      .sort_by {|tuple| tuple[0].start_time}
      .map {|tuple| build_joined_call(*tuple)}
  end

  private
  def directional_inbound_records
    from_customer = @calls.select {|call| call.direction == 'inbound' && call.parent_call_sid.nil?}
    joined_calls = from_customer.map {|cust_call| [cust_call, @calls.find {|call| call.parent_call_sid == cust_call.sid}]}  

    # populate b-legs and recording urls
    joined_calls_with_recordings = joined_calls.map do |a_leg, b_leg|
      b_leg ||= @client.calls.list(parent_call_sid: a_leg.sid).first
      tuple = [
        a_leg, 
        @client.calls.list(parent_call_sid: a_leg.sid).first,
        a_leg.recordings.list.first
      ]
      tuple
    end
  end

  def build_joined_call(a, b, recording = nil)
    success_statuses = ['completed', 'in-progress']
    answered_statuses = ['completed']

    cdr = Phone::CallDetailRecord.new()
    cdr.id = -1
    cdr.hotel = Phone::Contact.new({phone: PhoneNumber.new(a.to).to_s})
    cdr.customer = Phone::Contact.new(phone: PhoneNumber.new(a.from).to_s)
    cdr.legAId = a.sid
    cdr.direction = :INBOUND
    cdr.callTimeInSeconds = a.duration.to_i || -1
    cdr.timestamp = Google::Protobuf::Timestamp.from_time(a.start_time)

    if !b.nil?
      cdr.salesAgent = Phone::Contact.new({phone: PhoneNumber.new(b.to).to_s})
      cdr.legBId = b.sid
      cdr.callSucceeded = success_statuses.include?(b.status)
      cdr.callAnswered = answered_statuses.include?(b.status)
    else
      cdr.salesAgent = Phone::Contact.new({phone: "Not Configured"})
      cdr.legBId = "Not Configured"
      cdr.callSucceeded = false
      cdr.callAnswered = false
    end

    if !recording.nil?
      cdr.hasVoicemail = true
      # format /2010-04-01/Accounts/AC8ae12eec377d652cb9eeec90be804ba2/Recordings/RE171cc415c53a09714bac1f60a336cc1c.json
      recording.uri =~ /^(.*)\.json$/i

      cdr.voicemailUrl = "https://api.twilio.com#{$1}.wav"
    end
    cdr
  end
end
