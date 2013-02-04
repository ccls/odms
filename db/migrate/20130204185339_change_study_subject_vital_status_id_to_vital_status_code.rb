class ChangeStudySubjectVitalStatusIdToVitalStatusCode < ActiveRecord::Migration
	def change
		rename_column :study_subjects, :vital_status_id, :vital_status_code
	end
end
