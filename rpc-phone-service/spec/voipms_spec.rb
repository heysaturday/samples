require 'voipms'
require 'phone_pb'
require 'date'

describe VoipMsProvider, "#available_numbers" do
  before :all do
    @client = VoipMsProvider.new({
      user: ENV['VOIPMS_USER'], 
      password: ENV['VOIPMS_PASS']
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
      nh_did = numbers.select {|did| did.did == "6018820840"}.first

      expect(nh_did).to_not be_nil
      expect(nh_did.franchise).to eq("Comfort Inn")
      expect(nh_did.city).to eq("Jackson")
      expect(nh_did.state).to eq("MS")
    end

    it "does not contain any pending did orders" do
      numbers = @client.available_numbers
      nonconforming = numbers.select {|did| !(/^\d+$/.match(did.did)) }

      expect(nonconforming.count).to eq(0)
    end
  end

  context "call history service" do
    it "can return call detail records in the old cdr format" do
      start = Date.parse("01-06-2017")
      end_date = Date.parse("30-06-2017")
      cdrs = @client.call_history(start, end_date)

      expect(cdrs).to be_an(Array)
      expect(cdrs.count).to be > 0
      expect(cdrs.first).to be_an(VoipMsCallDetailRecord)
    end
  end
end
