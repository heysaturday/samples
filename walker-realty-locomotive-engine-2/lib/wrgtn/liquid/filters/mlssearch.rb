module Wrgtn
  module Liquid
    module Filters
      module MLSSearch
        @@max_page_size = 20
        @@zip_regex = /^[\d ,]+$/i
        @@word_regex = /^[a-zA-Z\s,]+$/
        @@mixed_regex = /^[\d\w\s,]+$/i
        @@single_integer = /^\s*\d+\s*$/
        @@single_decimal = /^\s*[\d,.]+\s*$/

      	# property=neighborhood:74,elementary_school:Patrick Henry,neighborhood:5&bedrooms=&price-min=&price-max=&home-type=detached&home-type=attached&home-type=condo&acreage=
        # TODO one day support more than just single family homes
      	# Query string parameters that we care about: all params will be in comma  delimited lists
      	# zip, subarea, area, city, subdivision, bedrooms -- eventually garages, acres, schools, etc
      	#
        def match_criteria(homes, params)
		      # zips = validate(params['zipcodes'], @@zip_regex)
          # subareas = validate(params['subareas'], @@word_regex, true)
          # areas = validate(params['areas'], @@word_regex, true)
          # cities = validate(params['cities'], @@word_regex, true)
          # subdivisions = validate(params['subdivisions'], @@mixed_regex, true)
          areas = validate_multiarea_field(params['areas'])
          bedrooms = validate(params['bedrooms'], @@single_integer)
          min_price = validate(params['minprice'], @@single_decimal)
          max_price = validate(params['maxprice'], @@single_decimal)
          full_bathrooms = validate(params['fullbaths'], @@single_integer)
          half_bathrooms = validate(params['halfbaths'], @@single_integer)
          garages = validate(params['garages'], @@single_integer)
          acres = validate(params['acres'], /^(\d+|\w+)$/i)
          sqft = validate(params['sqft'], @@single_integer)

          # Acres
          acres = acres.nil? ? "" : acres.first
          case acres
          when /\d+/
            acres_lo = acres.to_f
            acres_hi = nil
          when "half"
            acres_lo = 0.0
            acres_hi = 0.5
          when "whole"
            acres_lo = 0.5
            acres_hi = 1.0
          else
            acres_lo = nil
            acres_hi = nil
          end

          #Sqft
          sqft = !sqft.nil? ? sqft.first.to_i : nil
          case sqft
          when 0
            sqft_lo = 0 
            sqft_hi = 1000
          when 1000
            sqft_lo = 1000
            sqft_hi = 1500
          when 1500
            sqft_lo = 1500
            sqft_hi = 2000
          when 2000
            sqft_lo = 2000
            sqft_hi = 2500
          when 2500
            sqft_lo = 2500
            sqft_hi = 3000
          when 3000
            sqft_lo = 3000
            sqft_hi = 3500
          when 3500
            sqft_lo = 3500
            sqft_hi = nil
          else
            sqft_lo = nil
            sqft_hi = nil
          end 

          query = homes.collection       

          query = query.gte(bedrooms_count: bedrooms.first) if !bedrooms.nil?
          query = query.gte(price: min_price.first)   if !min_price.nil?
          query = query.lte(price: max_price.first)   if !max_price.nil?
          
          query = query.gte(acres: acres_lo)          if !acres_lo.nil?
          query = query.lte(acres: acres_hi)          if !acres_hi.nil?

          query = query.gte(sqft: sqft_lo)          if !sqft_lo.nil?
          query = query.lte(sqft: sqft_hi)          if !sqft_hi.nil?
          
          query = query.gte(full_baths_count: full_bathrooms.first) if !full_bathrooms.nil?
          query = query.gte(half_baths_count: half_bathrooms.first) if !half_bathrooms.nil?
          query = query.where(parking_type: /#{garages.first}\+? Car Garage/) if !garages.nil?
          query = query.desc(:price)
          
          areas.each do |complex_criteria|
            query = complex_criteria.add_search_criteria(query)
          end

          puts query.inspect

          obj = Wrgtn::Liquid::Drops::SingleFamilyHomes.new
          obj.set_collection query
          return obj
        end

        def page_size(params)
        	size = params["pagesize"] 
        	if size != nil
        		if  (size.is_a? Numeric  && 
        			size <= @@max_page_size &&
        			size > 0)
        			return size.to_i
        		end
          end
			   return @@max_page_size
        end

        private 
        def validate_multiarea_field(input)
          search_criteria = []
          return search_criteria if input.blank?
          csv = input.split(',')

          csv.each do |potential_search_term|
            if potential_search_term =~ /^[\w\d\s:.]+$/i
              values = potential_search_term.split(':')
              
              if values.length == 3
                search_criteria << AttributeSearchCriteria.new(values[0], values[1], values[2])
              elsif values.length == 2
                search_criteria << AreaSearchCriteria.new(values[1])
              end
            end
          end

          return search_criteria
        end

        def validate(input, regex, convert=false)
          return nil if input.blank?
          return nil if !(input =~ regex)
          results = filter_any(input.split(/[,]+/i))
          results = results.map {|r| r.strip}
          (convert) ? to_regexes(results) : results
        end

        def filter_any(input)
          output = input.select {|i| !(i =~ /any/i)}
          return (output.blank?) ? nil : output
        end

        def to_regexes(input)
          return nil if input.nil?
          Regexp.new(Regexp.union(input).source, true)
        end

      	::Liquid::Template.register_filter(MLSSearch)


        class AreaSearchCriteria
          attr_accessor :area

          def initialize(area)
            @area = area
          end

          def add_search_criteria(criteria)
            return criteria.or(area: /#{@area}/i)
          end

        end

        class AttributeSearchCriteria
          attr_accessor :area, :attribute, :kind

          def initialize(kind, area, value)
            @kind = kind
            @area = area
            @value = value
          end

          def add_search_criteria(criteria)
            # Areas auto-completion box
            query = {area: /#{@area}/i}
            case @kind
              when "zip_codes"
                query[:zip] = @value
              when "sub_areas"
                query[:sub_area] = /#{@value}/i
              when "city_names"
                query[:city] = /#{@value}/i
              when "subdivisions"
                query[:subdivision] = /#{@value}/i 
              when "street_addresses"
                query[:mlsid] = @value
              when "streets"
                query[:street_name] = /#{@value}/i
            end
            return criteria.or(query)
          end
        end
  	  end
    end
  end
end
