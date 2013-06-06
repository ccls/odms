class RemoveVitalStatusCodeFromStudySubjects < ActiveRecord::Migration
	def up
		remove_column :study_subjects, :vital_status_code
	end

	def down
		add_column :study_subjects, :vital_status_code, :integer
	end
end
