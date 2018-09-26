require 'phone_pb'
require 'common'

class BridgedCallTransformer
  def self.to_cdr(call)
    cdr = Phone::CallDetailRecord.new()
    cdr.id = call[:id]
    cdr.hotel = Phone::Contact.new({
      id: call[:hotel_id],
      phone: call[:hotel_phone],
      name: call[:franchise].nil? ? "" : "#{call[:franchise]}: #{call[:city]}, #{call[:state]}"
    })
    cdr.salesAgent = Phone::Contact.new({
      id: call[:sales_agent_id],
      phone: call[:sales_agent_phone]
    })
    cdr.customer = Phone::Contact.new(phone: call[:customer_phone])
    cdr.legAId = call[:lega_sid]
    cdr.legBId = call[:legb_sid] || ""
    cdr.direction = (call[:direction] == "INBOUND") ? :INBOUND : :OUTBOUND
    cdr.callSucceeded = call[:connected] || false
    cdr.callAnswered = call[:answered] || false
    cdr.callTimeInSeconds = call[:duration] || -1 # -1 for "not yet finished"
    cdr.timestamp = Google::Protobuf::Timestamp.from_time(call[:timestamp])
    cdr.hasVoicemail = !call[:voicemail].empty?
    cdr.voicemailUrl = call[:voicemail] || ""
    cdr
  end

  def self.from_cdr(record)
    {
      hotel_id: record.hotel.id,
      hotel_phone: record.hotel.phone,
      sales_agent_id: record.salesAgent.id,
      sales_agent_phone: record.salesAgent.phone,
      customer_phone: record.customer.phone,
      lega_sid: record.legAId,
      direction: record.direction.to_s,
      connected: record.callSucceeded,
      answered: record.callAnswered,
      duration: record.callTimeInSeconds,
      timestamp: record.timestamp.to_time.to_datetime,
      voicemail: record.voicemailUrl
    }
  end
end
