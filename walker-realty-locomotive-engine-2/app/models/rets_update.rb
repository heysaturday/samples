require 'mongoid'

class RetsUpdate
      include Mongoid::Document
      include Mongoid::Timestamps::Created
      store_in session: "mls"

      field :property_class, type: String
      field :record_count, type: Integer
end
