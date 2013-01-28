class AddLegacyRaceCodeImportedToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :legacy_race_code_imported, :boolean, :default => false
	end
end
