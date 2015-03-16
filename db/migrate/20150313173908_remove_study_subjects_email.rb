class RemoveStudySubjectsEmail < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :email
  end
  def self.down
		add_column :study_subjects, :email, :string
		add_index :study_subjects, :email, :unique => true
  end
end
