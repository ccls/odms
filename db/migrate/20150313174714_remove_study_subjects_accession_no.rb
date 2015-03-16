class RemoveStudySubjectsAccessionNo < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :accession_no
  end
  def self.down
		add_column :study_subjects, :accession_no, :string, :limit => 25
		add_index :study_subjects, :accession_no, :unique => true
  end
end
