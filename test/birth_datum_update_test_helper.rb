module BirthDatumUpdateTestHelper

	def create_test_file_and_birth_datum_update(options={})
		create_birth_datum_update_test_file(options)
		birth_datum_update = create_birth_datum_update_with_file
	end

	def create_birth_datum_update_with_file
		birth_datum_update = Factory(:birth_datum_update,
			:csv_file => File.open(csv_test_file_name) )
		assert_not_nil birth_datum_update.csv_file_file_name
		birth_datum_update
	end

#
#	No longer necessary
#	Actually, should probably remove the source file.
#
	def cleanup_birth_datum_update_and_test_file(birth_datum_update=nil)
#		if birth_datum_update
#			birth_datum_update_file = birth_datum_update.csv_file.path
#			#	explicit destroy to remove attachment
#			birth_datum_update.destroy	
#			unless birth_datum_update_file.blank?
#				assert !File.exists?(birth_datum_update_file)
#			end
#			if File.exists?("test/birth_datum_update/#{birth_datum_update.id}") &&
#				File.directory?("test/birth_datum_update/#{birth_datum_update.id}")
#				Dir.delete("test/birth_datum_update/#{birth_datum_update.id}")
#			end
#		end
		if File.exists?(csv_test_file_name)
			#	explicit delete to remove test file
			File.delete(csv_test_file_name)	
		end
		assert !File.exists?(csv_test_file_name)
	end

	def create_case_for_birth_datum_update
		icf_master_id = Factory(:icf_master_id,:icf_master_id => '12345FAKE')
		study_subject = Factory(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		assert_equal '12345FAKE', study_subject.icf_master_id
		study_subject
	end

#
#	This should match BirthDataUpdate.expected_column_names
#
	def csv_file_header_array
	#	%w{masterid ca_co_status biomom biodad date mother_full_name mother_maiden_name father_full_name child_full_name child_dobm child_dobd child_doby child_gender birthplace_country birthplace_state birthplace_city mother_hispanicity mother_hispanicity_mex mother_race mother_race_other father_hispanicity father_hispanicity_mex father_race father_race_other}
		%w( masterid found_in_state_db match_confidence case_control_flag birth_state sex dob ignore1 ignore2 ignore3 last_name first_name middle_name state_registrar_no county_of_delivery local_registrar_no local_registrar_district birth_type birth_order birth_weight_gms method_of_delivery abnormal_conditions apgar_1min apgar_5min apgar_10min complications_labor_delivery fetal_presentation_at_birth forceps_attempt_unsuccessful vacuum_attempt_unsuccessful mother_maiden_name mother_first_name mother_middle_name mother_residence_line_1 mother_residence_city mother_residence_county mother_residence_state mother_residence_zip mother_dob mother_birthplace mother_ssn mother_race_ethn_1 mother_race_ethn_2 mother_race_ethn_3 mother_hispanic_origin_code mother_yrs_educ mother_occupation mother_job_industry mother_received_wic mother_weight_pre_pregnancy mother_weight_at_delivery mother_height month_prenatal_care_began prenatal_care_visit_count complications_pregnancy length_of_gestation_days length_of_gestation_weeks last_menses_on live_births_now_living last_live_birth_on live_births_now_deceased term_count_pre_20_weeks term_count_20_plus_weeks last_termination_on daily_cigarette_cnt_3mo_preconc daily_cigarette_cnt_1st_tri daily_cigarette_cnt_2nd_tri daily_cigarette_cnt_3rd_tri father_last_name father_first_name father_middle_name father_dob father_ssn father_race_ethn_1 father_race_ethn_2 father_race_ethn_3 father_hispanic_origin_code father_yrs_educ father_occupation father_job_industry )
	end

	def csv_file_header
		csv_file_header_array.collect{|s|"\"#{s}\""}.join(',')
	end

	def csv_file_unknown(options={})
#		"1234FAKE,unknown,1,,1/18/2012,Jane Smith,Jones,John Smith,Jimmy Smith,1,6,2009,M,United States,CA,Bakersfield,2,2,1,,2,2,1,"
		c = unknown_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def csv_file_case_study_subject(options={})
#		"1234FAKE,case,1,,1/18/2012,Jane Smith,Jones,John Smith,Jimmy Smith,1,6,2009,M,United States,CA,Bakersfield,2,2,1,,2,2,1,"
		c = case_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def csv_file_control(options={})
#		c = control.merge(options)
		c = control_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def create_birth_datum_update_test_file(options={})
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject
			f.puts csv_file_control(options) }
	end

	def unknown_subject_hash
		{	:masterid => '12345FAKE' }
	end

	def case_subject_hash
		unknown_subject_hash.merge({
			:case_control_flag => 'case'
		})
	end

	def control_subject_hash
		unknown_subject_hash.merge({
			:case_control_flag => 'control'
		})
	end

#	#	broke it down like this so that can access and compare the attributes
#	def control
#		{	:masterid => '1234FAKE',
#			:ca_co_status => 'control',
#			:biomom => 1,
#			:biodad => nil,
#			:date => nil,
#			:mother_full_name => 'Jill Johnson',
#			:mother_maiden_name => 'Jackson',
#			:father_full_name => 'Jack Johnson',
#			:child_full_name => 'Michael Johnson',
#			:child_dobm => 1,
#			:child_dobd => 6,
#			:child_doby => 2009,
#			:child_gender => 'M',
#			:birthplace_country => 'United States',
#			:birthplace_state => 'CA',
#			:birthplace_city => 'Oakland',
#			:mother_hispanicity => 2,
#			:mother_hispanicity_mex => 2,
#			:mother_race => 1,
#			:other_mother_race => nil,
#			:father_hispanicity => 2,
#			:father_hispanicity_mex => 2,
#			:father_race => 1,
#			:other_father_race => nil }
#	end

	def turn_off_paperclip_logging
		#	Is there I way to silence the paperclip output?  Yes...
		Paperclip.options[:log] = false
		#	Is there I way to capture the paperclip output for comparison?  Don't know.
	end

#	shouldn't be called test_... as makes it a test method!
	def csv_test_file_name
		"tmp/birth_datum_update_test_file.csv"
	end

end
