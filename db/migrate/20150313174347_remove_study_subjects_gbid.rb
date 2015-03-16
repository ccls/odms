class RemoveStudySubjectsGbid < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :gbid
  end
  def self.down
		add_column :study_subjects, :gbid, :string, :limit => 26
		add_index :study_subjects, :gbid, :unique => true
  end
end
