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

	def csv_file_header_array
		BirthDatumUpdate.expected_column_names
	end

	def csv_file_header
		csv_file_header_array.collect{|s|"\"#{s}\""}.join(',')
	end

	def csv_file_unknown(options={})
		c = unknown_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def csv_file_case_study_subject(options={})
		c = case_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def csv_file_control(options={})
		c = control_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def create_birth_datum_update_test_file(options={})
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject
			f.puts csv_file_control(options) }
	end

	#	just enough for no exceptions
	def unknown_subject_hash
		Factory.attributes_for(:birth_datum,
			:master_id => '12345FAKE' )
	end

	def case_subject_hash
		Factory.attributes_for(:case_birth_datum,
			:master_id => '12345FAKE' )
	end

	def control_subject_hash
		Factory.attributes_for(:control_birth_datum,
			:master_id => '12345FAKE' )
	end

#	shouldn't be called test_... as makes it a test method!
#	def csv_test_file_name
#		"tmp/birth_datum_update_test_file.csv"
#	end

end
