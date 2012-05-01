class CreateBirthDataUpdates < ActiveRecord::Migration
	def self.up
		create_table :birth_data_updates do |t|
			t.timestamps
		end
	end

	def self.down
		drop_table :birth_data_updates
	end
end
