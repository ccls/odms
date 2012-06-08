class RemoveAbstractsCountFromStudySubject < ActiveRecord::Migration
	def up
		remove_column :study_subjects, :abstracts_count
	end

	def down
		add_column :study_subjects, :abstracts_count, :integer, :default => 0
	end
end
