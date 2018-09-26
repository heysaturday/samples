
module Wrgtn
  module Liquid
    module Drops
      class SingleFamilyHome < Locomotive::Liquid::Drops::Base
        delegate :parking_type, :fireplace_type, :architecture_style, :construction_type, :cooling_type, 
          :heating_type, :flooring, :foundation, :display, :mls_id_alt, :list_agency_office_id, :distressed_status, 
          :listing_date, :foundation, :sub_area, :fireplace_count, :hoa_fee, :city_taxes, :expiration_date, :county_taxes, 
          :sold_date, :entry_date, :pics_count, :pics_timestamp, :days_on_market, :contract_date, :public_remarks, 
          :elementary_school, :middle_school, :high_school, :classification, :fallthrough_date, :status, :docs_timestamp, 
          :docs_count, :status_change_date, :temp_off_market_date, :cancel_date, :pending_status, :internal_listing_id, 
          :orig_price, :sold_price, :finance, :mlsid_prefix, :house_num, :street_direction, :street_name,
          :unit_num, :street_suffix, :city, :mlsid, :state, :zip, :latitude, :longitude, :sqft, :approved, :year_built, 
          :cancel_reason, :lot_size, :acres, :list_agent_id, :sell_agent_id, :rooms_count, :bedrooms_count, 
          :full_baths_count, :half_baths_count, :is_in_subdivision, :taxes_total, :subdivision, :timestamp, 
          :hoa_participation_required, :sewer, :prop_type, :water, :new_construction_status, :sqft_source, 
          :hoa_dues_period, :property_type, :listing_agent_name, :listing_office_name, :selling_agent_name, 
          :selling_office_name, :virtual_tour_unbranded, :photos, :street_address, to: :@_source

        def primary_photo
          photos = @_source.photos.select {|photo| photo.primary }
          puts photos.inspect  
          return photos.first if (photos.count > 0)
          return @_source.photos.first
        end

        def baths
          baths = (@_source.full_baths_count || 0)
          baths += (@_source.half_baths_count || 0) * 0.5
          return baths
        end

        def neighborhood
          if @_source.is_in_subdivision == "Yes"
            @_source.subdivision
          else
            @_source.sub_area =~ /- ([\w ]+)/i
            $1
          end
        end

        def area
            @_source.area =~ /([\w ]+) -/i
            $1
        end

        def price
          ActionController::Base.helpers.number_to_currency(@_source.price)
        end

        def slug
          "/listings/sf?id=#{@_source.mlsid}"
        end
      end

      class Photo < Locomotive::Liquid::Drops::Base
        delegate :hi_res, :file_name, :primary, to: :@_source
      end

      class SingleFamilyHomes < ::Liquid::Drop
        def set_collection(collection)
          @collection = collection
        end

        def first
          self.collection.first
        end

        def last
          self.collection.last
        end

        def each(&block)
          self.collection.each(&block)
        end

        def each_with_index(&block)
          self.collection.each_with_index(&block)
        end

        def size
          self.collection.count
        end

        alias :count :size
        alias :length :size

        

        def paginate(options = {})
          @collection = @collection.page(options[:page] || 1).per(options[:per_page] || 10)
          total_entries = @collection.total_count
          total_entries = 100 if total_entries > 100
          total_pages = (total_entries/options[:per_page]).ceil
          last_page = (options[:page] == total_pages)

          {
            :collection       => self,
            :current_page     => @collection.current_page,
            :previous_page    => @collection.first_page? ? nil : self.collection.current_page - 1,
            :next_page        => last_page ? nil : self.collection.current_page + 1,
            :total_entries    => @collection.total_count,
            :total_pages      => total_pages,
            :per_page         => @collection.options[:limit]
          }
        end

        def collection
          @collection ||= ::SingleFamilyHome.where(display: "Y")
        end
      end


    end
  end
end