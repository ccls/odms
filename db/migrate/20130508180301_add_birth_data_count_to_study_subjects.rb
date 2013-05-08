class AddBirthDataCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :birth_data_count, :integer, :default => 0
	end
end
