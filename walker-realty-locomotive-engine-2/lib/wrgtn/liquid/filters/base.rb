require 'active_support'

module Wrgtn
  module Liquid
    module Filters
      module Base

        include ActionView::Helpers::NumberHelper

        def money_with_currency(price)
          number_to_currency(price)
        end

        def money_without_currency(price)
          number_to_currency(price, :unit => '')
        end

        def find_by_mlsid(mongoid_query, id)
          num = id.to_i
          return nil if num.nil? || num < 1 || num.is_a?(Bignum)
          return mongoid_query.collection.where(mlsid: num).first
          
        end

        def first(mongoid_query)
          return mongoid_query.collection.first
        end

        def in_area(mongoid_query, area)
          new_coll_with mongoid_query.collection.where(area: /^#{area}/i)
        end

        def less_than(mongoid_query, attribute, value)
          new_coll_with mongoid_query.collection.lt(attribute => value)
        end

        def greater_than(mongoid_query, attribute, value)
          new_coll_with mongoid_query.collection.gt(attribute => value)
        end

        def where(mongoid_query, attribute, value)
          new_coll_with mongoid_query.collection.where(attribute => value)
        end

        def active(mongoid_query)
	  status_in(mongoid_query, "Active")
        end

        def pending(mongoid_query)
          status_in(mongoid_query, [
            "Pending",
            "Pending - Continue to Show",
            "Pending - Continue to Show - Financing",
            "Pending - Continue to Show - Inspection",
            "Pending - Continue to Show - Property Sale",
            "Pending - Continue to Show - 1st Right of Refusal"
	  ])
        end

        def sold(mongoid_query)
          status_in(mongoid_query, "Closed")
        end

        def within_zipcodes(mongoid_query, zip_codes)
          zip_codes ||= ""
          zips = zip_codes.split(/[^\d]+/)
          new_coll_with mongoid_query.collection.in(zip: zips)
        end

        def sort_descending(mongoid_query, attribute)
          new_coll_with mongoid_query.collection.desc(attribute)
        end

        def sort_ascending(mongoid_query, attribute)
          new_coll_with mongoid_query.collection.asc(attribute)
        end

        def limit(mongoid_query, limit)
          new_coll_with mongoid_query.collection.limit(limit.to_i)
        end

        # date-related stuff
        def were_listed(mongoid_query)
          new_date_production mongoid_query.collection, :listing_date
        end

        def were_sold(mongoid_query)
          new_date_production mongoid_query.collection, :sold_date
        end

        def within_last_n_days(date_production, days)
          new_coll_with date_production.collection.gt(date_production.attribute => days.to_i.days.ago )
        end

        # basic types
        def count(mongoid_query)
          mongoid_query.count
        end

        def average_days_on_market(mongoid_query)
          query = mongoid_query.collection.only(:listing_date)
          return "N/A" if query.count == 0
          total_days = query.reduce(0) {|sum, home| sum += (Time.now - home.listing_date).to_i / 1.day }
          return (total_days / query.count.to_f).ceil
        end

        # Returns a float
        def average(mongoid_query, attribute)
          # query = mongoid_query.collection.ne(attribute.to_sym => nil).only(attribute)
          # return "0.0" if query.count == 0
          # return "---" if !query.first.respond_to?(attribute)
         
          # sum = query.reduce(0.0) {|sum, home| sum + home.send(attribute)}
          # return sum / query.count
          return mongoid_query.collection.avg(attribute) || 0
        end

        # string operations
        def pipify(base_string, input)
          return base_string if input.blank?
          return input if base_string.blank?
          "#{base_string} | #{input}"
        end

        def pipify_url(base_string, link, text)
          return base_string if link.blank?
          return "<a href='#{link}' target='_blank'>#{text}</a>" if base_string.blank?
          "#{base_string} | <a href='#{link}' target='_blank'>#{text}</a>"
        end

        def to_dollars(number, decimal_places=0)
            return number unless number.is_a? Numeric
            return number_to_currency(number, precision: decimal_places)
        end

        def decipher_url(url)
          absolute_uri = /^https?:\/\/.+/i
          page_uri = /^\/.+/i

          if url =~ absolute_uri || url =~ page_uri
            return url.downcase
          end
          return "#"
        end

        def status_in(mongo_query, status)
          if mongo_query.collection.is_a? Mongoid::Criteria
            return new_coll_with mongo_query.collection.union.in(status: status)
          else
            return new_coll_with mongo_query.collection.in(status: status)
          end
        end

        def new_coll_with(collection)
          obj = Wrgtn::Liquid::Drops::SingleFamilyHomes.new
          obj.set_collection collection
          obj
        end

        def new_date_production(collection, attribute)
          obj = Wrgtn::Liquid::Drops::DateProduction.new(nil)
          obj.new_production collection, attribute
          obj
        end


      end

      ::Liquid::Template.register_filter(Base)
    end
  end
end
