class DropUnits < ActiveRecord::Migration
	def up
		drop_table "units"
	end

	def down
		create_table "units" do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end

		add_index "units", ["description"], 
			:name => "index_units_on_description", :unique => true
		add_index "units", ["key"], 
			:name => "index_units_on_key", :unique => true
	end
end
