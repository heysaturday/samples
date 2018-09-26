require 'twilio'
require 'phone_pb'


describe TwilioProvider do
  before :all do
    @client = TwilioProvider.new({
      sid: ENV['TWILIO_SID'], 
      token: ENV['TWILIO_TOKEN'], 
      incoming_number: "8650000000", 
      bridge_code_url: ['TWILIO_CALL_BRIDGE_URL']
    })
  end

  context "number service" do
    it "can return hotel numbers in the correct format" do
      numbers = @client.available_numbers

      expect(numbers).to be_an(Array)
      expect(numbers.count).to be > 0
      expect(numbers[0]).to be_an(Phone::HotelDid)
    end

    it "can parse properly-formatted friendly names" do
      numbers = @client.available_numbers
      nh_did = numbers.select {|did| did.did == "+16038210406"}.first

      expect(nh_did).to_not be_nil
      expect(nh_did.franchise).to eq("Quality Inn")
      expect(nh_did.city).to eq("Merrimack")
      expect(nh_did.state).to eq("New Hampshire")
    end
  end

  context "call history" do
    it "can retrieve both legs of incoming calls" do
      start_date, end_date = Date.new(2017, 11, 19), Date.new(2017, 11, 20)
      incoming_calls = @client.call_history(start_date, end_date)

      calls_with_voicemail = incoming_calls.select {|call| call.hasVoicemail}

      expect(incoming_calls.count).to eq(5)
      expect(calls_with_voicemail.count).to eq(2)
      expect(calls_with_voicemail.first.customer.phone).to eq("+1 (603) 417-8857")
      expect(calls_with_voicemail.first.salesAgent.phone).to eq("+1 (856) 952-3082")
      expect(calls_with_voicemail.first.hotel.phone).to eq("+1 (603) 821-0406")
      expect(calls_with_voicemail.first.voicemailUrl).to include("REb34b7025c719254c745465ad9ab953c0")
    end
  end
end
