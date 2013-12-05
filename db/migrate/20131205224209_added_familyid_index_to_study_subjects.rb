class AddedFamilyidIndexToStudySubjects < ActiveRecord::Migration
	def change
		add_index :study_subjects, :familyid
	end
end
