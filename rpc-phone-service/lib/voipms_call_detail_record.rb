require 'values'
require 'phone_number'
require 'active_support'
require 'active_support/core_ext/date_and_time/zones'

class VoipMsCallDetailRecord < Value.new(:id, :date, :status, :direction, :cname, :seconds, :destination, :source) 
  def duration
    Time.at(@seconds).utc.strftime("%T")
  end

  def is_valid?
    @source.is_valid? && @destination.is_valid?
  end

  def build_joined_call(to, direction=:outbound)
    is_inbound = (direction == :inbound)
    VoipMsCallDetailRecord.with({
      id: self.id,
      date: self.date,
      source: is_inbound ? self.source : to.source,
      destination: to.destination,
      status: to.status,
      seconds: [self.seconds, to.seconds].min,
      cname: is_inbound ? self.destination : to.cname,
      direction: direction
    })
  end

  def self.from_hash(hash={}) 
    VoipMsCallDetailRecord.with({
      id: hash['uniqueid'].to_i || -1,
      date: (hash['date'] || "1970-01-01").in_time_zone("Eastern Time (US & Canada)"),
      source: (hash['callerid'] =~ /<(\d+)>/) ? PhoneNumber.new($1) : PhoneNumber.new,
      destination: PhoneNumber.new(hash['destination']),
      cname: (hash['callerid'] =~ /"([^"]+)"/) ? $1 : "Unknown", 
      status: (hash['disposition'] || "Not Attempted").capitalize,
      seconds: hash['seconds'].to_i || 0,
      direction: 'Unknown'
    })
  end
end
