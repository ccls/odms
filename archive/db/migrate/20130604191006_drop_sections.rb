class DropSections < ActiveRecord::Migration
	def up
		drop_table "sections"
	end

	def down
		create_table "sections" do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end

		add_index "sections", ["key"], 
			:name => "index_sections_on_key", :unique => true
	end
end
