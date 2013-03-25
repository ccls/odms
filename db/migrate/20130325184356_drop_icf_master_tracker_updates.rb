class DropIcfMasterTrackerUpdates < ActiveRecord::Migration
	def up
		drop_table "icf_master_tracker_updates"
	end

	def down
		create_table "icf_master_tracker_updates" do |t|
			t.date     "master_tracker_date"
			t.datetime "created_at",            :null => false
			t.datetime "updated_at",            :null => false
			t.string   "csv_file_file_name"
			t.string   "csv_file_content_type"
			t.integer  "csv_file_file_size"
			t.datetime "csv_file_updated_at"
		end
	end
end
