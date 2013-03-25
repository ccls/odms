class DropIcfMasterTrackerChanges < ActiveRecord::Migration
	def up
		drop_table "icf_master_tracker_changes"
	end

	def down
		create_table "icf_master_tracker_changes" do |t|
			t.string   "icf_master_id", :null => false
			t.date     "master_tracker_date"
			t.boolean  "new_tracker_record",  :default => false, :null => false
			t.string   "modified_column"
			t.string   "previous_value"
			t.string   "new_value"
			t.datetime "created_at", :null => false
			t.datetime "updated_at", :null => false
		end

		add_index "icf_master_tracker_changes", ["icf_master_id"], :name => "index_icf_master_tracker_changes_on_icf_master_id"
	end
end
