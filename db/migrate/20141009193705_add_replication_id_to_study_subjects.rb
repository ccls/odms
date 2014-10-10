class AddReplicationIdToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :replication_id, :integer
		add_index  :study_subjects, :replication_id
	end
end
