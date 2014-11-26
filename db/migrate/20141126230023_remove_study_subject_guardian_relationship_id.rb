class RemoveStudySubjectGuardianRelationshipId < ActiveRecord::Migration
	def up
		remove_column :study_subjects, :guardian_relationship_id
	end
	def down
		add_column :study_subjects, :guardian_relationship_id, :integer
	end
end
