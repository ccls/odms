class ChangeStudySubjectMotherRaceIdToMotherRaceCode < ActiveRecord::Migration
	def up
		rename_column :study_subjects, :mother_race_id, :mother_race_code
	end

	def down
		rename_column :study_subjects, :mother_race_code, :mother_race_id
	end
end
