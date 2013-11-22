class AddPhaseCaseIcfMasterIdIndexToStudySubjects < ActiveRecord::Migration
	def change
		add_index :study_subjects, [:phase, :case_icf_master_id]
	end
end
