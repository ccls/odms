class CreateAddresses < ActiveRecord::Migration
	def self.up
		create_table :addresses do |t|
			t.integer  :study_subject_id
			t.integer  :current_address, default: 1
			t.integer  "address_at_diagnosis"
			t.string   "other_data_source"
			t.timestamps
			t.text     "notes"
			t.string   "data_source"
			t.string   "line_1"
			t.string   "line_2"
			t.string   "city"
			t.string   "state"
			t.string   "zip",                  limit: 10
			t.integer  "external_address_id"
			t.string   "county"
			t.string   "unit"
			t.string   "country"
			t.boolean  "needs_geocoded", default: true
			t.boolean  "geocoding_failed", default: false
			t.float    "longitude"
			t.float    "latitude"
			t.text     "geocoding_response"
			t.string   "address_type"
		end

		add_index :addresses, :external_address_id, :unique => true
		add_index :addresses, ["needs_geocoded", "geocoding_failed"], 
			name: "index_addresses_on_needs_geocoded_and_geocoding_failed"
		add_index :addresses, :study_subject_id
	end

	def self.down
		drop_table :addresses
	end
end
