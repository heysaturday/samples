require 'active_support'
require 'active_support/core_ext'

class PhoneNumber
  def initialize(val="")
    validate!(val)
  end

  def value
    return "Invalid Phone Number" if @invalid
    "#{@country_code}#{@area_code}#{@central_office}#{@subscriber_number}"
  end

  def <=>(another_number)
    value <=> another_number.value
  end

  def to_s
    return "Invalid Phone Number" if @invalid
    "+#{@country_code} (#{@area_code}) #{@central_office}-#{@subscriber_number}"
  end

  def is_valid?
    !@invalid
  end
  
  private
  def validate!(val)
    return if val.blank?
    if val =~ /(\d+)(\d{3})(\d{3})(\d{4})/
      @country_code = $1
      @area_code = $2
      @central_office = $3
      @subscriber_number = $4
      @invalid = false
    elsif val =~ /(\d{3})(\d{3})(\d{4})/
      @country_code = 1
      @area_code = $1
      @central_office = $2
      @subscriber_number = $3
      @invalid = false
    elsif val =~ /\+(\d+) \((\d{3})\) (\d{3})-(\d{4})/
      @country_code = $1
      @area_code = $2
      @central_office = $3
      @subscriber_number = $4
      @invalid = false
    else
      @invalid = true
    end
  end
end
