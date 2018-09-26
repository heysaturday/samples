
require 'phone_pb'
class DidTransformer
  def self.did_from_db(hash)
    Phone::HotelDid.new({
      id: hash[:id],
      did: hash[:did],
      hotelId: hash[:hotel_id],
      franchise: hash[:franchise],
      city: hash[:city],
      state: hash[:state],
      salesAgentId: hash[:sales_agent_id]
    })
  end
end
