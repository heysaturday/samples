module Wrgtn
  module Liquid
    module Drops
      class DateProduction < Locomotive::Liquid::Drops::Base
      	def new_production(collection, attribute)
      		@collection = collection
      		@attribute = attribute
      	end

      	def collection
      		@collection
      	end

      	def attribute
      		@attribute
      	end

      end
    end
  end
end

