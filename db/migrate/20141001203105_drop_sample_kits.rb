class DropSampleKits < ActiveRecord::Migration
	def self.down
		create_table :sample_kits do |t|
			t.integer :sample_id
#	this is kinda pointless without packages.
#			t.integer :kit_package_id
#			t.integer :sample_package_id
			t.timestamps
		end
	end

	def self.up
		drop_table :sample_kits
	end
end
