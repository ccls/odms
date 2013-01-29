class AddLegacyOtherRaceToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :legacy_other_race, :string
	end
end
