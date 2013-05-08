class AddAddressingsCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :addressings_count, :integer, :default => 0
	end
end
