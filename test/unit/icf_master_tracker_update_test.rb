require 'test_helper'

class IcfMasterTrackerUpdateTest < ActiveSupport::TestCase

	teardown :cleanup_icf_master_tracker_update_and_test_file	#	remove tmp/FILE.csv

	test "should send email on missing required column" do
		icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
		assert_raises(SystemExit){
		assert_difference('ActionMailer::Base.deliveries.length',1) {
			icf_master_tracker_update.required_column('fake_column')
		} }
		mail = ActionMailer::Base.deliveries.detect{|m|
			m.subject.match(/ICF Master Tracker missing (.*) column/) }
		assert mail.to.include?('jakewendt@berkeley.edu')
		assert_match 'ICF Master Tracker missing', mail.body.encoded
		cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
	end

	test "should send email when csv file exists" do
		File.stubs(:exists?).returns(true)
		icf_master_tracker_update = nil
		assert_raises(SystemExit){
		assert_difference('ActionMailer::Base.deliveries.length',1) {
			icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
		} }
		mail = ActionMailer::Base.deliveries.detect{|m|
			m.subject.match(/Duplicate ICF Master Tracker/) }
		assert mail.to.include?('jakewendt@berkeley.edu')
		assert_match 'ICF Master Tracker has the same modification time as a previously', mail.body.encoded
		File.unstub(:exists?)
		cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
	end


	test "should archive" do
		File.stubs(:rename).returns(true)
		icf_master_tracker_update = IcfMasterTrackerUpdate.new(
				'test/assets/empty_icf_master_tracker_update_test_file.csv',:verbose => true)
		icf_master_tracker_update.archive
	end

	test "should test with real data file" do
		#	real data and won't be in repository
		real_data_file = 'ICF_Master_Tracker_20130416.csv'
		unless File.exists?(real_data_file)
			puts
			puts "-- Real data test file does not exist. Skipping."
			return 
		end

#		#	minimal semi-real case creation
#		s0 = Factory(:study_subject,:sex => 'F',
#			:first_name => 'FakeFirst1',:last_name => 'FakeLast1', 
#			:dob => Date.parse('10/16/1977'))
#
#		s1 = Factory(:study_subject,:sex => 'F',
#			:first_name => 'FakeFirst2',:last_name => 'FakeLast2', 
#			:dob => Date.parse('9/21/1988'))
#		Factory(:icf_master_id,:icf_master_id => '15270110G')
#		s1.assign_icf_master_id
#
#		s2 = Factory(:study_subject,:sex => 'M',
#			:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
#			:dob => Date.parse('6/1/2009'))
#		Factory(:icf_master_id,:icf_master_id => '15397125B')
#		s2.assign_icf_master_id

		icf_master_tracker_update = IcfMasterTrackerUpdate.new(real_data_file)
		assert_not_nil icf_master_tracker_update.csv_file

#	kinda difficult to test this as nothing is ActiveRecord

#		assert_difference('IcfMasterTrackerChange.count',1861){
#		and also the master_id changed (irrelevant so changed callback)
#		assert_difference('IcfMasterTrackerChange.count',1958){
#		assert_difference('IcfMasterTracker.count',95){
#			results = icf_master_tracker_update.parse
#			assert_equal results.length, 95
#			assert_nil   results[0].study_subject
#			assert_equal results[1].study_subject, s1
#			assert_equal results[2].study_subject, s2
#			results.each { |r|
#				assert  r.is_a?(IcfMasterTracker)
#				assert !r.new_record?
#				assert  r.flagged_for_update
#			}
#		} }
#
#	TODO add some tests to see if anything was updated
#
	end

	test "should change subjects interview_completed_on with cati_complete value" do
		study_subject = create_case_for_icf_master_tracker_update
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker_update = create_test_file_and_icf_master_tracker_update("cati_complete" => '12/31/2000')
		assert_not_nil study_subject.ccls_enrollment.reload.interview_completed_on
		assert_equal Date.parse('12/31/2000'),study_subject.ccls_enrollment.interview_completed_on
	end


protected

	def create_test_file_and_icf_master_tracker_update(options={})
		create_icf_master_tracker_update_test_file(options)
		icf_master_tracker_update = create_icf_master_tracker_update_with_file
	end

	def create_icf_master_tracker_update_with_file
#		icf_master_tracker_update = Factory(:icf_master_tracker_update,
#			:csv_file => File.open(csv_test_file_name) )
#		assert_not_nil icf_master_tracker_update.csv_file_file_name
#		icf_master_tracker_update
		icf_master_tracker_update = IcfMasterTrackerUpdate.new(csv_test_file_name)
	end

	def cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update=nil)
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
#		IcfMasterTrackerUpdate.expected_column_names
##		master_id case_master_id control_number 
##      date_control_released master_id_mother language record_owner 
##      record_status record_status_date date_received last_attempt 
##      last_disposition curr_phone record_sent_for_matching 
##      record_received_from_matching sent_pre_incentive released_to_cati 
##      confirmed_cati_contact refused deceased_notification 
##      screened ineligible_reason confirmation_packet_sent 
##      cati_protocol_exhausted new_phone_released_to_cati 
##      plea_notification_sent case_returned_for_new_info 
##      case_returned_from_berkeley cati_complete kit_mother_sent 
##      kit_infant_sent kit_child_sent kid_adolescent_sent kit_mother_refused_code 
##      kit_child_refused_code no_response_to_plea response_received_from_plea 
##      sent_to_in_person_followup kit_mother_received kit_child_received 
##      thank_you_sent physician_request_sent physician_response_received 
##      vaccine_auth_received recollect
		%w( master_id case_master_id cati_complete )
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
			"master_id" => "1234FAKE"	#, "master_id_mother" => "4567FAKE"		#	why?
		}
	end

	def create_icf_master_tracker_update_test_file(options={})
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_study_subject(options)
		}
	end

	#	shouldn't be called test_... as makes it a test method!
	def csv_test_file_name
		"tmp/icf_master_tracker_update_test_file.csv"
	end

end
