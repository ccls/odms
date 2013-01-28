class AddHispanicityMexToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :hispanicity_mex, :integer
	end
end
