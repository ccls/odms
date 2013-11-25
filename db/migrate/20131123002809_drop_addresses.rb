class DropAddresses < ActiveRecord::Migration
	def up
		drop_table :addresses
		remove_column :addressings,  :address_id
	end

	def down
		create_table :addresses do |t|
			t.integer "address_type_id"
			t.string   "line_1"
			t.string   "line_2"
			t.string   "city"
			t.string   "state"
			t.string   "zip",  :limit => 10
			t.integer  "external_address_id"
			t.string   "county"
			t.string   "unit"
			t.string   "country"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
			t.boolean  "needs_geocoded",  :default => true
			t.boolean  "geocoding_failed",  :default => false
			t.float    "longitude"
			t.float    "latitude"
			t.text     "geocoding_response"
			t.string   "address_type"
		end
		add_index "addresses",  ["external_address_id"],  
			:name => "index_addresses_on_external_address_id",  :unique => true
		add_column :addressings,  :address_id,  :integer
	end
end
