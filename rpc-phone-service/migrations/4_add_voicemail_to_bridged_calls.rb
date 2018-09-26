
Sequel.migration do
  change do
    add_column :bridged_calls, :voicemail, String
  end
end
