class AddNeedsGeocodedGeocodingFailedIndexToAddressings < ActiveRecord::Migration
	def change
		add_index :addressings, [:needs_geocoded,:geocoding_failed]
	end
end
