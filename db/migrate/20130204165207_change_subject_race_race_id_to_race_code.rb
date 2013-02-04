class ChangeSubjectRaceRaceIdToRaceCode < ActiveRecord::Migration
	def change
		rename_column :subject_races, :race_id, :race_code
	end
end
