class AddedMatchingidIndexToStudySubjects < ActiveRecord::Migration
	def change
		add_index :study_subjects, :matchingid
	end
end
