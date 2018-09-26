require 'date'
require 'mongoid'
require 'active_support'
require_relative './photo.rb'
require 'yaml'

class SingleFamilyHome
      include Mongoid::Document
      store_in session: "mls"

      def self.resource; "Property" ; end
      def self.klass; "A" ; end

      @@attr_map = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + "/singlefamily.yml")

      # Setup each of the class keys
      @@attr_map.each do |id, info|
            field info[:attr_name], type: Kernel.const_get(info[:class])
      end

      def street_address
            "#{house_num} #{street_direction.blank? ? '' : street_direction + ' '}#{street_name} #{street_suffix}#{unit_num.blank? ? '' : " #" + unit_num}" 
      end

      def street
            "#{street_direction.blank? ? '' : street_direction + ' '}#{street_name} #{street_suffix}" 
      end

      def self.mlsfield_from_attrname(attr_name)
            @@attr_map.find {|k,v| v[:attr_name] == attr_name.to_sym}.first
      end

      def self.primary_key()
            :mlsid
      end

      def self.object_key()
            :internal_listing_id
      end

      def self.primary_key_mlsfield()
            mlsfield_from_attrname(primary_key)
      end

      def self.object_key_mlsfield()
            mlsfield_from_attrname(object_key)
      end

      def to_s()
            "#{@house_num} #{@street_name}"
      end

      embeds_many :photos

      # Setup indexes
      index({mlsid: 1}, {unique: true, name: "mlsid_1"})

      def to_liquid
       Wrgtn::Liquid::Drops::SingleFamilyHome.new(self)  
      end
end


