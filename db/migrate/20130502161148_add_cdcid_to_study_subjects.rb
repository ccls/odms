class AddCdcidToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :cdcid, :string, :limit => 12
	end
end
