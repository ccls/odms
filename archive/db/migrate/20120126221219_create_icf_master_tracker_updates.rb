class CreateIcfMasterTrackerUpdates < ActiveRecord::Migration
	def self.up
		create_table :icf_master_tracker_updates do |t|
			t.date :master_tracker_date
			t.timestamps
		end
	end

	def self.down
		drop_table :icf_master_tracker_updates
	end
end
