class AddNeedsReindexedIndexToStudySubjects < ActiveRecord::Migration
	def change
		add_index :study_subjects, :needs_reindexed
	end
end
