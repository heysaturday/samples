
Sequel.migration do
  change do
    create_table(:bridged_calls) do
      primary_key :id
      Integer :hotel_id, index: true
      String :hotel_phone
      Integer :sales_agent_id
      String :sales_agent_phone
      String :customer_phone
      DateTime :timestamp, index: true
      Integer :duration # seconds of duration
      Boolean :connected
      Boolean :answered
      String :direction
      String :lega_sid, index: {unique: true}
      String :legb_sid, index: true
    end
  end
end
