class AddAddressAttributesToAddressing < ActiveRecord::Migration
	def change
		add_column :addressings, :line_1, :string
		add_column :addressings, :line_2, :string
		add_column :addressings, :city, :string
		add_column :addressings, :state, :string
		add_column :addressings, :zip, :string, :limit => 10
		add_column :addressings, :external_address_id, :integer
		add_column :addressings, :county, :string
		add_column :addressings, :unit, :string
		add_column :addressings, :country, :string
		add_column :addressings, :needs_geocoded,   :boolean, :default => true
		add_column :addressings, :geocoding_failed, :boolean, :default => false
		add_column :addressings, :longitude, :float
		add_column :addressings, :latitude, :float
		add_column :addressings, :geocoding_response, :text
		add_column :addressings, :address_type, :string
	end
end
