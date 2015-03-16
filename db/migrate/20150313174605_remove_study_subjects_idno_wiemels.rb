class RemoveStudySubjectsIdnoWiemels < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :idno_wiemels
  end
  def self.down
		add_column :study_subjects, :idno_wiemels, :string, :limit => 10
		add_index :study_subjects, :idno_wiemels, :unique => true
  end
end
