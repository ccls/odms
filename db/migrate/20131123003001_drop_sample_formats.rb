class DropSampleFormats < ActiveRecord::Migration
	def up
		drop_table :sample_formats
		remove_column :samples, :sample_format_id
	end

	def down
		create_table :sample_formats do |t|
			t.integer  "position"
			t.string   "key",         :null => false
			t.string   "description"
			t.datetime "created_at",  :null => false
			t.datetime "updated_at",  :null => false
		end
	
		add_index "sample_formats", ["description"], :name => "index_sample_formats_on_description", :unique => true
		add_index "sample_formats", ["key"], :name => "index_sample_formats_on_key", :unique => true
		add_column :samples, :sample_format_id, :integer
	end
end
