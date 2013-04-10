class AddMotherIcfMasterIdToStudySubject < ActiveRecord::Migration
	def change
		add_column :study_subjects, :mother_icf_master_id, :string, :limit => 9
	end
end
