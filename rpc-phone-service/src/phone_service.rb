require 'phone_services_pb'
require 'common'
require 'bridged_call_transformer'
require 'phone_number'
require 'securerandom'
require 'did_transformer'
require 'cdr_transformer'
require 'time_difference'

class PhoneService < Phone::Phone::Service
  def initialize(twilio, voipms, db)
    @twilio = twilio
    @voipms = voipms
    @history = db[:bridged_calls]
    @dids = db[:hotel_dids]
    @assignments = db[:did_assignments]
    @db = db
  end

  def get_hotel_dids(_empty, _call)
    all_dids = @db["select * from active_phone_numbers"].map {|d| DidTransformer.did_from_db(d) }
    Phone::DidResponse.new(success: true, dids: all_dids)

  rescue StandardError => e
    Phone::DidResponse.new(success: false, message: e.message)
  end

  def initiate_bridged_call(call, _call)
    validate_call! call

    should_record = call.salesAgentId == 9

    response = @twilio.bridge_call(call.salesAgentPhone, call.customerPhone, call.hotelPhone, should_record)
    call_id = add_call_to_db(call, response, true)
    Phone::CallResponse.new(id: call_id, success: true, message: response.status)

  rescue Twilio::REST::RestError, Twilio::REST::ServerError => e
    call_id = add_call_to_db(call, nil, true)
    Phone::CallResponse.new(id: call_id, success: false, message: e.message)
  rescue PhoneNumberError => e
    Phone::CallResponse.new(id: -1, success: false, message: e.message)
  end

  def get_call_history(dateRange, _call)
    start_date = dateRange.start.to_time.to_datetime
    end_date = dateRange.end.to_time.to_datetime + 1

    cdrs = @history.
      graph(:hotel_dids, did: :hotel_phone).
      where{(timestamp <= end_date) & (timestamp >= start_date)}.
      order(:timestamp).
      map {|bc| BridgedCallTransformer.to_cdr(bc)}

    Phone::CallHistoryResponse.new(success: true, records: cdrs)
  rescue Sequel::Error => e
    Phone::CallHistoryResponse.new(success: false, message: e.message)
  end

  def update_in_progress_calls(_params, _call)
    orphaned_calls = []

    @history.where(answered: nil).map do |bridged_call|
      lega_sid = bridged_call[:lega_sid]
      legb = @twilio.get_b_leg(lega_sid)

      if (legb.nil?)
        hours_passed = TimeDifference.between(bridged_call[:timestamp], Time.now).in_hours
        orphaned_calls << bridged_call[:id] if (hours_passed > 1)
        next
      end

      @history
        .where(id: bridged_call[:id])
        .update({
          legb_sid: legb[:sid],
          connected: !legb[:failed],
          answered: legb[:answered],
          duration: legb[:duration]})
    end

    puts "Deleting #{orphaned_calls.count} orphaned calls"
    orphaned_calls.each {|c| @history.where(id: c).delete}
    Phone::Empty.new
  end

  def update_incoming_calls(_params, _call)
    start_date, end_date = Date.today-1, Date.today

    ## retrieve all inbound calls from voipms over the last day
    voipms_incoming = @voipms.
      call_history(start_date, end_date).
      select {|call| [:inbound, :INBOUND].include?(call.direction)}.
      map {|call| CdrTransformer.from_voipms(call)}

    ## retrieve all inbound calls from twilio over the same date range
    twilio_all = @twilio.call_history(start_date, end_date)
    twilio_incoming = twilio_all.
      select {|call| [:inbound, :INBOUND].include?(call.direction)}
    
    ## remove the calls that are not hotel-related
    dids = @dids.select(:hotel_id, :did).all
    hotel_dids = dids.reduce({}) do |hash, obj| 
      hash[obj[:did]] = obj[:hotel_id]
      hash
    end

    # add the correct sales agent to the call
    qualified_calls = (voipms_incoming + twilio_incoming).
      map {|call| call.hotel.id = hotel_dids[call.hotel.phone] || -1; call}.
      select {|call| call.hotel.id >= 0}.
      map do |call| 
        assignment = @assignments.
          select(:sales_agent_id).
          where{Sequel.&({hotel_id: call.hotel.id}, (starting_from <= call.timestamp.to_date))}.
          order_by(Sequel.desc(:starting_from)).
          limit(1)
          .first

        call.salesAgent.id = assignment[:sales_agent_id]
        call
      end
    
    # insert into the db
    formatted_calls = qualified_calls.map {|call| BridgedCallTransformer.from_cdr(call)}
    formatted_calls.each do |formatted_call| 
      begin
        @history.insert formatted_call
      rescue Sequel::UniqueConstraintViolation => e
        puts e.message
      end
    end

    return Phone::Empty.new

  rescue Sequel::Error => e
    return Phone::Empty.new
  end

  private
  # Returns a integer for the primary key
  def add_call_to_db(bridged_call_request, twilio_response, success=false)
    return -1 if bridged_call_request.isTestCall

    @history.insert({
      hotel_id: bridged_call_request.hotelId,
      hotel_phone: PhoneNumber.new(bridged_call_request.hotelPhone).to_s,
      sales_agent_id: bridged_call_request.salesAgentId,
      sales_agent_phone: PhoneNumber.new(bridged_call_request.salesAgentPhone).to_s,
      customer_phone: PhoneNumber.new(bridged_call_request.customerPhone).to_s,
      lega_sid: (twilio_response.nil?) ? SecureRandom.hex : twilio_response.sid,
      direction: 'OUTBOUND', 
      connected: success,
      timestamp: DateTime.now
    })
  end

  def validate_call!(call)
    phones = [:salesAgentPhone, :hotelPhone, :customerPhone]
    phones.each do |contact|
      unvalidated = call.send(contact)
      phone_number = PhoneNumber.new(unvalidated) 
      raise PhoneNumberError.new "Phone number provided for #{contact} was #{unvalidated}, which is not a valid phone number" if !phone_number.is_valid?
      call.send("#{contact}=", phone_number.to_s)
    end
  end
end
