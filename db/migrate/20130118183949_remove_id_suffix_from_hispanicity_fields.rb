class RemoveIdSuffixFromHispanicityFields < ActiveRecord::Migration
	def up
		rename_column :study_subjects, :hispanicity_id, :hispanicity
		rename_column :study_subjects, :mother_hispanicity_id, :mother_hispanicity
		rename_column :study_subjects, :father_hispanicity_id, :father_hispanicity
	end

	def down
		rename_column :study_subjects, :hispanicity, :hispanicity_id
		rename_column :study_subjects, :mother_hispanicity, :mother_hispanicity_id
		rename_column :study_subjects, :father_hispanicity, :father_hispanicity_id
	end
end
