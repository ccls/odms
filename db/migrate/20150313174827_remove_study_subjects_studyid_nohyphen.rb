class RemoveStudySubjectsStudyidNohyphen < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :studyid_nohyphen
  end
  def self.down
		add_column :study_subjects, :studyid_nohyphen, :string, :limit => 12
		add_index :study_subjects, :studyid_nohyphen, :unique => true
  end
end
