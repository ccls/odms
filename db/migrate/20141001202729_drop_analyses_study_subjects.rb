class DropAnalysesStudySubjects < ActiveRecord::Migration
	def self.down
		create_table :analyses_study_subjects, :id => false do |t|
			t.integer :analysis_id
			t.integer :study_subject_id
		end
		add_index :analyses_study_subjects, :analysis_id
		add_index :analyses_study_subjects, :study_subject_id
	end

	def self.up
		drop_table :analyses_study_subjects
	end
end
