class CreateBirthData < ActiveRecord::Migration
	def change
		create_table :birth_data do |t|
			t.integer :study_subject_id
			t.string  :abnormal_conditions, :length => 2
			t.integer :apgar_1min
			t.integer :apgar_5min
			t.integer :apgar_10min
			t.integer :birth_order
			t.string  :birth_type
			t.decimal :birth_weight_gms
			t.string  :complications_labor_delivery, :length => 2
			t.string  :complications_pregnancy, :length => 2
			t.string  :county_of_delivery
			t.integer :daily_cigarette_cnt_1st_tri
			t.integer :daily_cigarette_cnt_2nd_tri
			t.integer :daily_cigarette_cnt_3rd_tri
			t.integer :daily_cigarette_cnt_3mo_preconc
			t.date    :dob
			t.string  :father_job_industry, :length => 20
			t.date    :father_dob
			t.string  :father_hispanic_origin_code, :length => 15
			t.string  :father_first_name
			t.string  :father_last_name
			t.string  :father_middle_name
			t.string  :father_occupation, :length => 20
			t.string  :father_race_ethnicity, :length => 15
#father_ssn
			t.integer :father_years_education
			t.string  :fetal_presentation_at_birth
			t.string  :first_name
			t.boolean :forceps_attempt_unsuccessful
			t.date    :last_live_birth_on
			t.date    :last_menses_on
			t.string  :last_name
			t.date    :last_termination_on
			t.integer :length_of_gestation_days
			t.integer :live_births_now_deceased
			t.integer :live_births_now_living
			t.string  :local_registrar_district
			t.string  :local_registrar_no
			t.string  :method_of_delivery, :length => 10
			t.string  :middle_name
			t.string  :month_prenatal_care_began
			t.string  :mother_residence_county_ef
			t.string  :mother_residence_line_1
			t.string  :mother_residence_zip
			t.integer :mother_weight_at_delivery
			t.string  :mother_birthplace_state
			t.string  :mother_residence_city
			t.date    :mother_dob
			t.string  :mother_first_name
			t.integer :mother_height
			t.string  :mother_hispanic_origin_code
			t.string  :mother_industry
			t.string  :mother_maiden_name
			t.string  :mother_middle_name
			t.string  :mother_occupation
			t.string  :mother_race_ethnicity
			t.boolean :mother_received_wic
			t.string  :mother_residence_state
#mother_ssn
			t.integer :mother_weight_pre_pregnancy
			t.integer :mother_years_education
			t.integer :ob_gestation_estimate_at_delivery
			t.integer :prenatal_care_visit_count
			t.string  :sex
			t.string  :state_registrar_no
			t.integer :termination_count_20_plus_weeks
			t.integer :termination_count_before_20_weeks
			t.boolean :vacuum_attempt_unsuccessful
			t.timestamps
		end
	end
end
