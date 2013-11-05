class DropTracingStatuses < ActiveRecord::Migration
	def up
		drop_table "tracing_statuses"
	end

	def down
		create_table "tracing_statuses", :force => true do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description", :null => false
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end

		add_index "tracing_statuses", ["description"], 
			:name => "index_tracing_statuses_on_description", 
			:unique => true
		add_index "tracing_statuses", ["key"], 
			:name => "index_tracing_statuses_on_key", 
			:unique => true
	end
end
