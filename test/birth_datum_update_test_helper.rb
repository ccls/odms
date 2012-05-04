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
		icf_master_id = Factory(:icf_master_id,:icf_master_id => '1234FAKE')
		study_subject = Factory(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		assert_equal '1234FAKE', study_subject.icf_master_id
		study_subject
	end

#
#	This should match BirthDataUpdate.expected_column_names
#
	def csv_file_header_array
		%w{masterid ca_co_status biomom biodad date mother_full_name mother_maiden_name father_full_name child_full_name child_dobm child_dobd child_doby child_gender birthplace_country birthplace_state birthplace_city mother_hispanicity mother_hispanicity_mex mother_race mother_race_other father_hispanicity father_hispanicity_mex father_race father_race_other}
	end

	def csv_file_header
		csv_file_header_array.collect{|s|"\"#{s}\""}.join(',')
	end

	def csv_file_unknown
		"1234FAKE,unknown,1,,1/18/2012,Jane Smith,Jones,John Smith,Jimmy Smith,1,6,2009,M,United States,CA,Bakersfield,2,2,1,,2,2,1,"
	end

	def csv_file_case_study_subject
		"1234FAKE,case,1,,1/18/2012,Jane Smith,Jones,John Smith,Jimmy Smith,1,6,2009,M,United States,CA,Bakersfield,2,2,1,,2,2,1,"
	end

	def csv_file_control(options={})
		c = control.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def create_birth_datum_update_test_file(options={})
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject
			f.puts csv_file_control(options) }
	end

	#	broke it down like this so that can access and compare the attributes
	def control
		{	:masterid => '1234FAKE',
			:ca_co_status => 'control',
			:biomom => 1,
			:biodad => nil,
			:date => nil,
			:mother_full_name => 'Jill Johnson',
			:mother_maiden_name => 'Jackson',
			:father_full_name => 'Jack Johnson',
			:child_full_name => 'Michael Johnson',
			:child_dobm => 1,
			:child_dobd => 6,
			:child_doby => 2009,
			:child_gender => 'M',
			:birthplace_country => 'United States',
			:birthplace_state => 'CA',
			:birthplace_city => 'Oakland',
			:mother_hispanicity => 2,
			:mother_hispanicity_mex => 2,
			:mother_race => 1,
			:other_mother_race => nil,
			:father_hispanicity => 2,
			:father_hispanicity_mex => 2,
			:father_race => 1,
			:other_father_race => nil }
	end

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
