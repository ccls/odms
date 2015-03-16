class RemoveStudySubjectsLabNoWiemels < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :lab_no_wiemels
  end
  def self.down
		add_column :study_subjects, :lab_no_wiemels, :string, :limit => 25
		add_index :study_subjects, :lab_no_wiemels, :unique => true
  end
end
