class AddSfnFromCdphToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :sfn_from_cdph, :string, :limit => 10
	end
end
