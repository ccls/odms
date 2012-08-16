module IcfMasterTrackerUpdateTestHelper

	def create_test_file_and_icf_master_tracker_update(options={})
		create_icf_master_tracker_update_test_file(options)
		icf_master_tracker_update = create_icf_master_tracker_update_with_file
	end

	def create_icf_master_tracker_update_with_file
		icf_master_tracker_update = Factory(:icf_master_tracker_update,
			:csv_file => File.open(csv_test_file_name) )
		assert_not_nil icf_master_tracker_update.csv_file_file_name
		icf_master_tracker_update
	end

#
#	Don't think I need this anymore.  Just removing the whole directory after each test.
#	Actually, should probably remove the source file.
#
	def cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update=nil)
#		if icf_master_tracker_update
#			icf_master_tracker_update_file = icf_master_tracker_update.csv_file.path
#			#	explicit destroy to remove attachment
#			icf_master_tracker_update.destroy	
#			unless icf_master_tracker_update_file.blank?
#				assert !File.exists?(icf_master_tracker_update_file)
#			end
#			if File.exists?("test/icf_master_tracker_update/#{icf_master_tracker_update.id}") &&
#				File.directory?("test/icf_master_tracker_update/#{icf_master_tracker_update.id}")
#				Dir.delete("test/icf_master_tracker_update/#{icf_master_tracker_update.id}")
#			end
#		end
		if File.exists?(csv_test_file_name)
			#	explicit delete to remove test file
			File.delete(csv_test_file_name)	
		end
		assert !File.exists?(csv_test_file_name)
	end

	def create_case_for_icf_master_tracker_update
		icf_master_id = Factory(:icf_master_id,:icf_master_id => '1234FAKE')
		study_subject = Factory(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		assert_equal '1234FAKE', study_subject.icf_master_id
		study_subject
	end

	def csv_file_header_array
		IcfMasterTrackerUpdate.expected_column_names
	end

	def csv_file_header
		csv_file_header_array.collect{|s|"\"#{s}\""}.join(',')
	end

	def csv_file_study_subject(options={})
		subject = study_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{subject[s]}\""}.join(',')
	end

	#	no factory for this, although could create one (a bit excessive)
	def study_subject_hash
		{
			"master_id" => "1234FAKE",
			"master_id_mother" => "4567FAKE"
		}
	end

	def create_icf_master_tracker_update_test_file(options={})
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_study_subject(options)
		}
	end

#	shouldn't be called test_... as makes it a test method!
#	def csv_test_file_name
#		"tmp/icf_master_tracker_update_test_file.csv"
#	end

end
