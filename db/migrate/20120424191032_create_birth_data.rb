class CreateBirthData < ActiveRecord::Migration
	def change
		create_table :birth_data do |t|
			t.integer :birth_datum_update_id
			t.integer :study_subject_id	#	the actual study subject
#			t.string  :master_id	#	case icf_master_id
			t.string  :masterid	#	case icf_master_id
			t.boolean :found_in_state_db
			t.string  :birth_state
			t.string  :match_confidence
			t.string  :case_control_flag
			t.integer :length_of_gestation_weeks
			t.integer :father_race_ethn_1
			t.integer :father_race_ethn_2
			t.integer :father_race_ethn_3
			t.integer :mother_race_ethn_1
			t.integer :mother_race_ethn_2
			t.integer :mother_race_ethn_3

			t.string  :abnormal_conditions	#	shoulda had :limit => 2, not :length => 2
			t.integer :apgar_1min
			t.integer :apgar_5min
			t.integer :apgar_10min
			t.integer :birth_order
			t.string  :birth_type
			t.decimal :birth_weight_gms
			t.string  :complications_labor_delivery	#	shoulda had :limit => 2, not :length => 2
			t.string  :complications_pregnancy	#	shoulda had :limit => 2, not :length => 2
			t.string  :county_of_delivery
			t.integer :daily_cigarette_cnt_1st_tri
			t.integer :daily_cigarette_cnt_2nd_tri
			t.integer :daily_cigarette_cnt_3rd_tri
			t.integer :daily_cigarette_cnt_3mo_preconc
			t.date    :dob
			t.string  :first_name
			t.string  :middle_name
			t.string  :last_name

			t.string  :father_industry
			t.date    :father_dob
			t.string  :father_hispanic_origin_code	#	should had :limit => 15, not :length => 15
			t.string  :father_first_name
			t.string  :father_middle_name
			t.string  :father_last_name
			t.string  :father_occupation	#	shoulda had :limit => 20, not :length => 20
			t.integer :father_yrs_educ
			t.string  :fetal_presentation_at_birth
			t.boolean :forceps_attempt_unsuccessful
			t.date    :last_live_birth_on
			t.date    :last_menses_on
			t.date    :last_termination_on
			t.integer :length_of_gestation_days
			t.integer :live_births_now_deceased
			t.integer :live_births_now_living
			t.string  :local_registrar_district
			t.string  :local_registrar_no
			t.string  :method_of_delivery	#	should had :limit => 10, not :length => 10
			t.string  :month_prenatal_care_began
			t.string  :mother_residence_line_1
			t.string  :mother_residence_city
			t.string  :mother_residence_county		#	NEW
			t.string  :mother_residence_county_ef
			t.string  :mother_residence_state
			t.string  :mother_residence_zip
			t.integer :mother_weight_at_delivery
			t.string  :mother_birthplace					#	NEW
			t.string  :mother_birthplace_state
			t.date    :mother_dob
			t.string  :mother_first_name
			t.string  :mother_middle_name
			t.string  :mother_maiden_name
			t.integer :mother_height
			t.string  :mother_hispanic_origin_code
			t.string  :mother_industry
			t.string  :mother_occupation
			t.boolean :mother_received_wic
			t.integer :mother_weight_pre_pregnancy
			t.integer :mother_yrs_educ
			t.integer :ob_gestation_estimate_at_delivery
			t.integer :prenatal_care_visit_count
			t.string  :sex
			t.string  :state_registrar_no
			t.integer :term_count_20_plus_weeks
			t.integer :term_count_pre_20_weeks
			t.boolean :vacuum_attempt_unsuccessful
			t.timestamps
		end
	end
end
