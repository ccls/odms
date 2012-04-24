class RenameLiveBirthDataUpdateToBirthDataUpdate < ActiveRecord::Migration
	def up
		rename_table :live_birth_data_updates, :birth_data_updates
	end

	def down
		rename_table :birth_data_updates, :live_birth_data_updates
	end
end
