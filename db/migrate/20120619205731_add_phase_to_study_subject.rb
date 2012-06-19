class AddPhaseToStudySubject < ActiveRecord::Migration
	def change
		add_column :study_subjects, :phase, :integer
	end
end
