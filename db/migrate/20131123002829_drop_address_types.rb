class DropAddressTypes < ActiveRecord::Migration
	def up
		drop_table :address_types
	end

	def down
		create_table :address_types do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end
		add_index "address_types", ["key"], :name => "index_address_types_on_key", :unique => true
	end
end
