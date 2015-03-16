class RemoveStudySubjectsBirthCounty < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :birth_county
  end
  def self.down
		add_column :study_subjects, :birth_county, :string
  end
end
