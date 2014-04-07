require 'test_helper'

class MedicalRecordRequestTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to( :study_subject )
	assert_should_protect( :study_subject_id, :study_subject )

	attributes = %w( request_type status )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :request_type, :status, :maximum => 250 )
	assert_should_require_attribute_length( :notes, :maximum => 65000 )

	assert_should_accept_only_good_values( :status,
		{ :good_values => MedicalRecordRequest.statuses,
			:bad_values  => 'Funky' })

	test "statuses should return an array of strings" do
		statuses = MedicalRecordRequest.statuses
		assert statuses.is_a?(Array)
		assert_equal 4, statuses.length
		statuses.each { |s| assert s.is_a?(String) }
	end

	test "medical_record_request factory should create bc request" do
		assert_difference('MedicalRecordRequest.count',1) {
			medical_record_request = FactoryGirl.create(:medical_record_request)
			assert_match /Notes\d*/, medical_record_request.notes
		}
	end

	test "should return self for to_s if no study subject" do
		medical_record_request = MedicalRecordRequest.new
		assert_match /^#<MedicalRecordRequest:0x.+>$/, "#{medical_record_request}"
	end

	test "should include active medical record request in active scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'active' )
		medical_record_requests = MedicalRecordRequest.active
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include waitlist medical record request in waitlist scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'waitlist' )
		medical_record_requests = MedicalRecordRequest.waitlist
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include pending medical record request in pending scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'pending' )
		medical_record_requests = MedicalRecordRequest.pending
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include complete medical record request in complete scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'complete' )
		medical_record_requests = MedicalRecordRequest.complete
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include nil medical record request in incomplete scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => nil )
		medical_record_requests = MedicalRecordRequest.incomplete
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include active medical record request in incomplete scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'active' )
		medical_record_requests = MedicalRecordRequest.incomplete
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include waitlist medical record request in incomplete scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'waitlist' )
		medical_record_requests = MedicalRecordRequest.incomplete
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should include pending medical record request in incomplete scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'pending' )
		medical_record_requests = MedicalRecordRequest.incomplete
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should NOT include complete medical record request in incomplete scope" do
		medical_record_request = FactoryGirl.create(:medical_record_request,
			:status => 'complete' )
		medical_record_requests = MedicalRecordRequest.incomplete
		assert !medical_record_requests.include?( medical_record_request )
	end

	test "should return study subject's studyid for to_s if study subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('MedicalRecordRequest.count',1) {
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			medical_record_request = FactoryGirl.create(:medical_record_request)
			study_subject.medical_record_requests << medical_record_request
			assert_equal study_subject.studyid, "#{medical_record_request}"
		} }
	end

	test "should return medical_record_requests with status blank" do
		medical_record_request = FactoryGirl.create(:medical_record_request)
		assert medical_record_request.status.blank?
		assert MedicalRecordRequest.with_status().include?(medical_record_request)
	end

	test "should return medical_record_requests with status bogus" do
		blank_medical_record_request = FactoryGirl.create(:medical_record_request)
		assert blank_medical_record_request.status.blank?
		medical_record_request = FactoryGirl.create(:medical_record_request)
		assert  medical_record_request.status.blank?
		medical_record_requests = MedicalRecordRequest.with_status('bogus')
		assert !medical_record_requests.include?(medical_record_request)
		assert !medical_record_requests.include?(blank_medical_record_request)
	end

	MedicalRecordRequest.statuses.each do |status|
		test "should return medical_record_requests with status #{status}" do
			blank_medical_record_request = FactoryGirl.create(:medical_record_request)
			assert blank_medical_record_request.status.blank?
			medical_record_request = FactoryGirl.create(:medical_record_request, :status => status)
#			assert !medical_record_request.status.blank?
			assert medical_record_request.status.present?
			assert_equal status, medical_record_request.status
			medical_record_requests = MedicalRecordRequest.with_status(status)
			assert  medical_record_requests.include?(medical_record_request)
			assert !medical_record_requests.include?(blank_medical_record_request)
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_medical_record_request

end
