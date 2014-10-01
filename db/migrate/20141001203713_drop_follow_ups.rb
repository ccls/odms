class DropFollowUps < ActiveRecord::Migration
	def self.down
		create_table :follow_ups do |t|
			t.integer :section_id, :null => false
			t.integer :enrollment_id, :null => false
			t.integer :follow_up_type_id, :null => true
			t.date    :completed_on
			t.string  :completed_by_uid
			t.timestamps
		end
	end

	def self.up
		drop_table :follow_ups
	end
end
