class RemoveStudySubjectsLegacyOtherRace < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :legacy_other_race
  end
  def self.down
		add_column :study_subjects, :legacy_other_race, :string
  end
end
