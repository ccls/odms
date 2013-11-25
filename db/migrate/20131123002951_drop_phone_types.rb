class DropPhoneTypes < ActiveRecord::Migration
	def up
		drop_table :phone_types
		remove_column :phone_numbers, :phone_type_id
	end

	def down
		create_table :phone_types do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end
		add_index "phone_types", ["key"], :name => "index_phone_types_on_key", :unique => true
		add_column :phone_numbers, :phone_type_id, :integer
	end
end
