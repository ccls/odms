class AddVitalStatusToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :vital_status, :string, :limit => 20
		add_index  :study_subjects, :vital_status
	end
end
