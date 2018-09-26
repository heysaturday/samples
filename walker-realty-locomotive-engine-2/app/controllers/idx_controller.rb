require 'set'

class SearchController < ApplicationController

	def autocomplete
		area_map = value = Rails.cache.fetch('autocomplete')

		if params['callback']
			render json: area_map, :callback => params['callback']
		else
			render json: area_map
		end
	end

	def self.cache_areas
		area_map = areas()
		Rails.cache.write('autocomplete', area_map)
	end

	def self.areas
		area_map = {}
		areas = SingleFamilyHome.distinct(:area).map {|area| sanitize_mls_area(area) }.reject(&:blank?)

		areas.each do |area|
			area_map[area] = {} 
			area_map[area][:zip_codes] = base_search(area).distinct(:zip).reject(&:blank?)
			area_map[area][:sub_areas] = base_search(area).distinct(:sub_area).map {|area| sanitize_mls_area(area) }.reject(&:blank?)
			area_map[area][:city_names] = base_search(area).distinct(:city).reject(&:blank?)
			area_map[area][:subdivisions] = base_search(area).distinct(:subdivision).reject(&:blank?).
				map {|subdivision| sanitize(subdivision.downcase.strip) }.
				select {|s| valid_subdivision?(s) }.
				map(&:titleize).
				uniq.reject(&:blank?)
			#area_map[area][:schools] =  # TODO get school information hear
			
			area_map[area][:street_addresses] = []
			area_map[area][:streets] = Set.new

			# Collect every street address and street
			base_search(area).each do |house|
				area_map[area][:street_addresses] << {text: house.street_address(), id: house.mlsid}
				area_map[area][:streets] << {text: house.street, id: house.street_name}
			end
			area_map[area][:streets] = area_map[area][:streets].to_a

		end
		area_map
	end

	def self.base_search(area)
		SingleFamilyHome.where(display: "Y").where(area: /#{area}/).in(status: ["Active", /^pending/i])
	end

	def self.valid_subdivision?(name)
		return false if name.blank?
		!(name =~ /(\d+|#|&|^n.?a$|none|^$|applicable|[*~'"]|^.{1,4}$)/i)
	end

	def self.sanitize(name)
		return nil if (name =~ /(undefined|out of area)/i)
		name.gsub(/((s\/d|[.]{2,}|- |phase| ph | [.ivx]+ |subdivision| sec[. t]).*)/i, '').strip
	end

	def self.sanitize_mls_area(name)
		return nil if (name =~ /(undefined|out of area)/i)
		return name if name.nil?
		name.gsub(/(\s?-?\s?\d+\s?-?\s?)/i, '')
	end
end
