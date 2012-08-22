class AddIsStudyAreaResidentToPatients < ActiveRecord::Migration
	def change
		add_column :patients, :is_study_area_resident, :integer
	end
end
