class AddLegacyRaceCodeToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :legacy_race_code, :integer
	end
end
