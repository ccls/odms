class AddingGeocodingToAddresses < ActiveRecord::Migration
	def change
		add_column :addresses, :needs_geocoded, :boolean, :default => true
		add_column :addresses, :geocoding_failed, :boolean, :default => false
		add_column :addresses, :longitude, :float
		add_column :addresses, :latitude,  :float
		add_column :addresses, :geocoding_response, :text
	end
end
