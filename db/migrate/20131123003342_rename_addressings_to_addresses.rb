class RenameAddressingsToAddresses < ActiveRecord::Migration
	def up
		rename_table :addressings, :addresses
		rename_column :study_subjects, :addressings_count, :addresses_count
	end

	def down
		rename_table :addresses, :addressings
		rename_column :study_subjects, :addresses_count, :addressings_count
	end
end
