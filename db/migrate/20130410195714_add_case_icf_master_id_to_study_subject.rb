class AddCaseIcfMasterIdToStudySubject < ActiveRecord::Migration
	def change
		add_column :study_subjects, :case_icf_master_id, :string, :limit => 9
	end
end
