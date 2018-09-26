require 'mongoid'

class Photo
      include Mongoid::Document
      store_in session: "mls"

      def self.object_types; { "HiRes" => :hi_res }; end

      @@attr_map = {
            #"content-type"  => {attr_name: :content_type, description: "MIME Type" class: String}, 
            #"content-id"    => {attr_name: :resource_id,  description: "LIST_1, which is the resource identifier for the resource object representing this listing" class: String},
            "object-id"      => {attr_name: :photo_id,    description: "Unique photo identifier", class: Integer},
            #"location"       => {attr_name: :url,          description: "Url for this image", class: String },
            "preferred"      => {attr_name: :primary,      description: "Whether this is the main photo for the listing", class: Boolean },
            "content-description"=>  {attr_name: :file_name, description: "File name", class: String, default: false }
      }

      @@attr_map.each do |id, info|
            field info[:attr_name], type: info[:class], default: info[:default]
      end

      # Setup photo qualities
      object_types.values.each {|attr_name| field attr_name, type: String}

      embedded_in :single_family_home

      def to_liquid
        Wrgtn::Liquid::Drops::Photo.new(self)  
      end
end
