class AddCdcidToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :cdcid, :integer
	end
end
