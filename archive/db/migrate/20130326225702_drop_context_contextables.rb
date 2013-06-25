class DropContextContextables < ActiveRecord::Migration
	def up
		drop_table "context_contextables"
	end

	def down
		create_table "context_contextables" do |t|
			t.integer  "context_id"
			t.integer  "contextable_id"
			t.string   "contextable_type"
			t.datetime "created_at",       :null => false
			t.datetime "updated_at",       :null => false
		end
	end
end
