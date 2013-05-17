class AddNeedsReindexedToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :needs_reindexed, :boolean, :default => false
	end
end
