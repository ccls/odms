class AddGuardianRelationship < ActiveRecord::Migration
	def self.up
		add_column :study_subjects, :guardian_relationship, :string
	end
end
