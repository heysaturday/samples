
Sequel.migration do
  change do
    create_table(:hotel_dids) do
      primary_key :id
      String :did, index: {unique: true}
      Integer :hotel_id
      String :franchise
      String :city
      String :state
      Boolean :active
    end
  end
end
