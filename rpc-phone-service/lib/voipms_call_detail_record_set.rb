require 'voipms_call_detail_record'

class VoipMsCallDetailRecordSet
  @@inbound_account = "142662"
  @@outbound_account = "142662_c2c-cust-out"
  @@outbound_dos_account = "142662_c2c-dos-in"

  def initialize(api_response)
    @calls = api_response['cdr'] || []
    remove_invalid_calls!
  end

  def parse_records
    inbound_calls = find_pairs(*directional_inbound_records)
      .map {|pair| pair[0].build_joined_call(pair[1], :inbound)}
    
    outbound_calls = find_pairs(*directional_outbound_records)
      .map {|pair| pair[0].build_joined_call(pair[1], :outbound)}

    all_calls = inbound_calls + outbound_calls
    all_calls.select(&:is_valid?).sort_by(&:date)
  end

  private
  def remove_invalid_calls!
    @calls.reject! {|cdr| cdr['description'] =~ /echo/i }  # DID echo testing on 2/21/2017
    @calls.reject! {|cdr| cdr['destination'].length < 10 } # remove test calls to 4443
    @calls.reject! {|cdr| cdr['callerid'] =~ /<4443>/ }    # remove test calls from 4443
  end

  def directional_inbound_records
    inbound = @calls
      .select {|cdr| cdr['account'] == @@inbound_account}
      .group_by {|cdr| cdr['description'] =~ /inbound/i ? 'from_cust' : 'to_dos'} 
    [inbound['from_cust'] || [], inbound['to_dos'] || []]
  end

  def directional_outbound_records
    from_dos = @calls.select {|cdr| cdr['account'] == @@outbound_dos_account}
    to_cust  = @calls.select {|cdr| cdr['account'] == @@outbound_account}
    [from_dos, to_cust]
  end

  def find_pairs(inbound_list, outbound_list)
    to_cdr = Proc.new {|raw| VoipMsCallDetailRecord.from_hash(raw)}

    inbound = inbound_list.map(&to_cdr).sort_by(&:date)
    outbound = outbound_list.map(&to_cdr).sort_by(&:date)

    # Simply interleave call_legs when there are an equal number of them
    return inbound.zip(outbound) if inbound.length == outbound.length

    inbound = inbound.reverse!
    joined_calls = []
    # Since the record lists differed in length, that means that there were
    # errors during operation. The Voupms.join function sends the inbound call
    # first, then the outbound call, so it is reasonable that there would be
    # fewer outbound calls than inbound calls in the case of an error.
    outbound.each do |outbound_call|
      while inbound_call = inbound.pop
        if (outbound_call.date - inbound_call.date) * 1.day  < 30
          joined_calls << [inbound_call, outbound_call]
          break
        end
      end
    end

    joined_calls
  end
end
