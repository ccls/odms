class RemoveStudySubjectsLegacyRaceCode < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :legacy_race_code
  end
  def self.down
		add_column :study_subjects, :legacy_race_code, :integer
  end
end
