class RemoveStudySubjectsBirthDataCount < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :birth_data_count
  end
  def self.down
		add_column :study_subjects, :birth_data_count, :integer, :default => 0
  end
end
