require 'phone_pb'

class CdrTransformer 
  def self.from_voipms(old_cdr)
    if old_cdr.direction == :inbound
      Phone::CallDetailRecord.new({
        legAId: old_cdr.id.to_s,
        salesAgent: Phone::Contact.new(phone: old_cdr.destination.to_s),
        customer: Phone::Contact.new(phone: old_cdr.source.to_s),
        hotel: Phone::Contact.new(phone: old_cdr.cname.to_s),
        callSucceeded: old_cdr.status != "Failed",
        callAnswered: old_cdr.status == "Answered",
        callTimeInSeconds: old_cdr.seconds,
        direction: :INBOUND,
        timestamp: Google::Protobuf::Timestamp.from_date(old_cdr.date)
      })
    else # outbound 
      Phone::CallDetailRecord.new({
        legAId: old_cdr.id.to_s,
        salesAgent: Phone::Contact.new(id: 3, phone: "+1 (856) 952-3082"), # hardcoding Danielle
        customer: Phone::Contact.new(phone: old_cdr.destination.to_s),
        hotel: Phone::Contact.new(name: old_cdr.cname.to_s, phone: old_cdr.source.to_s),
        callSucceeded: old_cdr.status != "Failed",
        callAnswered: old_cdr.status == "Answered",
        callTimeInSeconds: old_cdr.seconds,
        direction: :OUTBOUND,
        timestamp: Google::Protobuf::Timestamp.from_date(old_cdr.date)
      })
    end
  end
end
