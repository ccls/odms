class DropOdmsExceptions < ActiveRecord::Migration
	def up
		drop_table :odms_exceptions
	end

	def down
		create_table :odms_exceptions do |t|
			t.integer  "exceptable_id"
			t.string   "exceptable_type"
			t.string   "name"
			t.string   "description"
			t.boolean  "is_resolved",     :default => false
			t.text     "notes"
			t.datetime "created_at",                         :null => false
			t.datetime "updated_at",                         :null => false
		end
	end
end
