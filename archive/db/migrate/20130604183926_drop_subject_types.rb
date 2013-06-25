class DropSubjectTypes < ActiveRecord::Migration

	def up
		drop_table "subject_types"
	end

	def down
		create_table "subject_types" do |t|
			t.integer  "position"
			t.string   "key", :null => false
			t.string   "description"
			t.string   "related_case_control_type"
			t.datetime "created_at", :null => false
			t.datetime "updated_at", :null => false
		end
		add_index "subject_types", ["description"], 
			:name => "index_subject_types_on_description", :unique => true
		add_index "subject_types", ["key"], 
			:name => "index_subject_types_on_key", :unique => true
	end

end
