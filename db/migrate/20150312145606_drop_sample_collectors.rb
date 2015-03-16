class DropSampleCollectors < ActiveRecord::Migration
	def self.down
		create_table :sample_collectors do |t|
			t.integer :organization_id
			t.string :other_organization
			t.timestamps
		end
		add_index :sample_collectors, :organization_id
	end
	def self.up
		drop_table :sample_collectors
	end
end
