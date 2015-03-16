class RemoveStudySubjectsLegacyRaceCodeImported < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :legacy_race_code_imported
  end
  def self.down
		add_column :study_subjects, :legacy_race_code_imported, :boolean, :default => false
  end
end
