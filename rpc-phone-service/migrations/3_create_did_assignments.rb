
Sequel.migration do
  change do
    create_table(:did_assignments) do
      Integer :hotel_id
      Integer :sales_agent_id
      Date :starting_from
    end
  end
end
