require 'sequel'
require 'google/protobuf/well_known_types'
require 'date'

Sequel.default_timezone = :utc
Sequel.datetime_class = DateTime

class PhoneNumberError < StandardError; end

class Google::Protobuf::Timestamp 
  def self.from_time(time)
    ts = self.new
    ts.from_time(time.to_time)
    ts
  end

  def self.from_date(date)
    ts = self.new
    ts.from_time(date.to_time)
    ts
  end

  def to_date()
    self.to_time.to_date
  end
end

class NilClass
  def empty?; true; end
end
