class DropContexts < ActiveRecord::Migration
	def up
		drop_table "contexts"
	end

	def down
		create_table "contexts" do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.text     "notes"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end
		add_index "contexts", ["description"], 
			:name => "index_contexts_on_description", :unique => true
		add_index "contexts", ["key"], 
			:name => "index_contexts_on_key", :unique => true
	end
end
