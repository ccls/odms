class RemoveStudySubjectsFatherGenerationalSuffix < ActiveRecord::Migration
  def self.up
		remove_column :study_subjects, :father_generational_suffix
  end
  def self.down
		add_column :study_subjects, :father_generational_suffix, :string, :limit => 10
  end
end
