class ReAddAbstractsCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :abstracts_count, :integer, :default => 0
	end
end
