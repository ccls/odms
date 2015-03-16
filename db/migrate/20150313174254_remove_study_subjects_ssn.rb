class RemoveStudySubjectsSsn < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :ssn
  end
  def self.down
		add_column :study_subjects, :ssn, :string
		add_index :study_subjects, :ssn, :unique => true
  end
end
