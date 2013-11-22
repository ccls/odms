class AddPhaseMotherIcfMasterIdIndexToStudySubjects < ActiveRecord::Migration
	def change
		add_index :study_subjects, [:phase, :mother_icf_master_id]
	end
end
