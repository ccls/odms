class AddLegacyRaceOtherToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :legacy_race_other, :string
	end
end
