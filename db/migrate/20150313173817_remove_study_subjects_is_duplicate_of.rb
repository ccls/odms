class RemoveStudySubjectsIsDuplicateOf < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :is_duplicate_of
  end
  def self.down
		add_column :study_subjects, :is_duplicate_of, :string, :limit => 6
  end
end
