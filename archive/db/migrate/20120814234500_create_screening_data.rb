class CreateScreeningData < ActiveRecord::Migration
	def change
		create_table :screening_data do |t|
			t.integer :screening_datum_update_id
			t.integer :study_subject_id
			t.string :icf_master_id
			t.integer :mom_is_biomom
			t.integer :dad_is_biodad
			t.string :mother_first_name
			t.string :mother_last_name
			t.string :mother_maiden_name
			t.string :father_first_name
			t.string :father_last_name
			t.string :first_name
			t.string :middle_name
			t.string :last_name
			t.date :dob
			t.string :sex
			t.string :birth_country
			t.string :birth_state
			t.string :birth_city
			t.integer :mother_hispanicity_mex
			t.string :other_mother_race
			t.integer :father_hispanicity_mex
			t.string :other_father_race
			t.string :new_mother_first_name
			t.string :new_mother_last_name
			t.string :new_mother_maiden_name
			t.string :new_father_first_name
			t.string :new_father_last_name
			t.string :new_first_name
			t.string :new_middle_name
			t.string :new_last_name
			t.date :new_dob
			t.string :new_sex
			t.datetime :date
			t.integer :dob_month
			t.integer :new_dob_month
			t.integer :dob_day
			t.integer :new_dob_day
			t.integer :dob_year
			t.integer :new_dob_year
			t.string :mother_hispanicity
			t.string :mother_race
			t.string :father_hispanicity
			t.string :father_race

			t.timestamps
		end
	end
end
