class RemovePatientIsStudyAreaResident < ActiveRecord::Migration
  def self.up
		remove_column :patients, :is_study_area_resident
  end
  def self.down
		add_column :patients, :is_study_area_resident, :integer
  end
end
