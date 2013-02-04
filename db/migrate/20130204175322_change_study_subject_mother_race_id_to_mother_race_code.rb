class ChangeStudySubjectMotherRaceIdToMotherRaceCode < ActiveRecord::Migration
	def change
		rename_column :study_subjects, :mother_race_id, :mother_race_code
	end
end
