class ChangeSubjectRaceRaceIdToRaceCode < ActiveRecord::Migration
	def up
		rename_column :subject_races, :race_id, :race_code
	end

	def down
		rename_column :subject_races, :race_code, :race_id
	end
end
