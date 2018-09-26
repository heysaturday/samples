require 'phone_service'
require 'google/protobuf/well_known_types'
require 'date'
require 'sequel'
require 'twilio'
require 'voipms'

describe PhoneService do
  before :all do
    params = {
      twilio: {
        sid: ENV['TWILIO_SID'],
        token: ENV['TWILIO_TOKEN'],
        bridge_code_url: ENV['TWILIO_CALL_BRIDGE_URL'],
        incoming_number: ENV['INCOMING_NUMBER'] 
      },
      test_twilio: {
        sid: ENV['TWILIO_TEST_SID'],
        token: ENV['TWILIO_TEST_TOKEN'],
        bridge_code_url: ENV['TWILIO_CALL_BRIDGE_URL'],
        incoming_number: ENV['INCOMING_NUMBER'] 
      },
      voipms: {
        user: ENV['VOIPMS_USER'],
        password: ENV['VOIPMS_PASS']
      }
    }

    @twilio = TwilioProvider.new params[:twilio]
    @test_twilio = TwilioProvider.new params[:test_twilio]
    @voipms = VoipMsProvider.new params[:voipms]
    @db = Sequel.connect(ENV['DB_CONNECTION'])
    @test_db = Sequel.connect("postgres://postgres@localhost/phone_service_test")

    @live_service = PhoneService.new(@twilio, @voipms, @db)
    @test_service = PhoneService.new(@test_twilio, @voipms, @test_db)
  end

  context "#get_hotel_dids" do
    before :all do
      @response = @live_service.get_hotel_dids(nil, nil)
    end

    it "returns the correct didresponse format" do
      expect(@response).to be_an(Phone::DidResponse)
    end

    it "returns more than one did in response" do
      expect(@response.message).to eq('')
      expect(@response.success).to be true
      expect(@response.dids.count).to be > 2
    end

    it "returns results from both voipms and twilio" do
      voipms_did = @response.dids.select {|hd| hd.did == '+1 (601) 882-0840'}.first
      twilio_did = @response.dids.select {|hd| hd.did == '+1 (603) 821-0406'}.first

      expect(voipms_did).to_not be_nil
      expect(twilio_did).to_not be_nil
    end
  end

  context "#initiate_bridged_call" do
    it "will initiate a call" 
    #do
    #  request = Phone::BridgedCallRequest.new(salesAgentPhone: "7049992425", customerPhone: "7045179293", hotelPhone: "5406059950", isTestCall: true)
    #  response = @live_service.initiate_bridged_call request, nil

    #  expect(response).to be_a(Phone::CallResponse)
    #  expect(response.message).to eq('queued')
    #  expect(response.success).to be true
    #end

    it "will fail when initiating a call against the test environment" do
      request = Phone::BridgedCallRequest.new(salesAgentPhone: "7049992425", customerPhone: "7045179293", hotelPhone: "5406059950", isTestCall: true)
      response = @test_service.initiate_bridged_call request, nil

      expect(response).to be_a(Phone::CallResponse)
      expect(response.message).to match(/(not yet verified|is not a valid phone number)/i)
      expect(response.success).to be false
    end

    it "will write the call to the database when not in test mode" do
      @calls = @test_db[:bridged_calls]
      call_count = @calls.count

      request = Phone::BridgedCallRequest.new(salesAgentPhone: "7049992425", customerPhone: "7045179293", hotelPhone: "5406059950", isTestCall: false)
      response = @test_service.initiate_bridged_call request, nil

      expect(@calls.count).to eq(call_count+1)
    end

    it "will insert the call into the database" do
      twilio  = double(bridge_call: double({status: "queued", sid: "testing123"}))
      dataset = double(insert: 755)
      db = double("[]" => dataset)
      
      expect(db).to receive("[]").with(:bridged_calls)
      expect(dataset).to receive(:insert).with(
        hash_including({
          sales_agent_id: 1, 
          sales_agent_phone: '+1 (704) 999-2425', 
          customer_phone: '+1 (704) 517-9293', 
          hotel_id: 1,
          hotel_phone: '+1 (540) 605-9950',
          lega_sid: 'testing123',
        })
      )

      service = PhoneService.new(twilio, double('voipms'), db)
      request = Phone::BridgedCallRequest.new({
        salesAgentPhone: "7049992425", 
        salesAgentId: 1,
        customerPhone: "7045179293", 
        hotelId: 1, 
        hotelPhone: "5406059950", 
        isTestCall: false
      })
      response = service.initiate_bridged_call request, nil

      expect(response).to be_a(Phone::CallResponse)
      expect(response.message).to eq('queued')
      expect(response.success).to be true
    end

    it "will not insert the call into the database if marked testing"

  end

  context "#get_call_history" do
    it "returns call history from database" do
      start_ts = Google::Protobuf::Timestamp.new
      start_ts.from_time (Date.today-30).to_time
      end_ts = Google::Protobuf::Timestamp.new
      end_ts.from_time (Date.today + 1).to_time

      dateRange = Phone::DateRangeFilter.new({
        start: start_ts,
        end: end_ts
      })
      response = @live_service.get_call_history(dateRange, nil)

      expect(response).to be_a(Phone::CallHistoryResponse)
      expect(response.message).to eq("")
      expect(response.success).to be true
      expect(response.records.count).to be > 0
    end

    it "can return a particular past result from voipms" do
      the_time = Date.parse("09-05-2017").to_time
      start_ts = Google::Protobuf::Timestamp.new
      start_ts.from_time the_time
      end_ts = Google::Protobuf::Timestamp.new
      end_ts.from_time the_time

      dateRange = Phone::DateRangeFilter.new({
        start: start_ts,
        end: end_ts
      })
      response = @live_service.get_call_history(dateRange, nil)

      expect(response).to be_a(Phone::CallHistoryResponse)
      expect(response.success).to be true
      expect(response.records.count).to eq(11) 

      matching_records = response.records.select {|cdr| cdr.callTimeInSeconds == 3}
      expect(matching_records.count).to eq(1)

      cdr = matching_records.first
      expect(cdr.customer.phone).to eq("+1 (618) 581-7942")
      expect(cdr.hotel.id).to eq(1)
      expect(cdr.hotel.name).to eq("Comfort Inn: Jackson, MS")
      expect(cdr.hotel.phone).to eq("+1 (601) 882-0840")
      expect(cdr.salesAgent.id).to eq(3)
      expect(cdr.salesAgent.phone).to eq("+1 (856) 952-3082")
      expect(cdr.salesAgent.name).to eq("")
    end

    it "does not change the time from the database" do
      the_time = Date.parse("09-05-2017").to_time
      start_ts = Google::Protobuf::Timestamp.new
      start_ts.from_time the_time
      end_ts = Google::Protobuf::Timestamp.new
      end_ts.from_time the_time

      dateRange = Phone::DateRangeFilter.new({
        start: start_ts,
        end: end_ts
      })

      response = @live_service.get_call_history(dateRange, nil)

      service_record = response.records.last
      db_record = @db[:bridged_calls].where(id: service_record.id).first

      expect(service_record.timestamp.to_time.to_datetime).to eq(db_record[:timestamp])
    end
  end

  context "update calls" do
    it "retrieves calls from voipms and twilio" do
      @live_service.update_incoming_calls(nil, nil)
    end

    it "updates inprogress calls from twilio" do
      @live_service.update_in_progress_calls(nil, nil)
    end
  end
end
