class AddStudySubjectIdIndexToSamples < ActiveRecord::Migration
	def change
		add_index :samples, :study_subject_id
	end
end
