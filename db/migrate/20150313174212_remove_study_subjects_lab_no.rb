class RemoveStudySubjectsLabNo < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :lab_no
  end
  def self.down
		add_column :study_subjects, :lab_no, :string
  end
end
