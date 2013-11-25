class DropSampleTemperatures < ActiveRecord::Migration
	def up
		drop_table :sample_temperatures
		remove_column :samples, :sample_temperature_id
	end

	def down
		create_table :sample_temperatures do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end
		add_index "sample_temperatures", ["key"], :name => "index_sample_temperatures_on_key", :unique => true
		add_column :samples, :sample_temperature_id, :integer
	end
end
