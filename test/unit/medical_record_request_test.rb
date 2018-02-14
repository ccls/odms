require 'test_helper'

class MedicalRecordRequestTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to( :study_subject )

	attributes = %w( is_found status )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )

	assert_should_require_attribute_length( :notes, :maximum => 65000 )

	assert_should_accept_only_good_values( :status,
		{ :good_values => MedicalRecordRequest.statuses,
			:bad_values  => 'Funky' })

	test "statuses should return an array of strings" do
		statuses = MedicalRecordRequest.statuses
		assert statuses.is_a?(Array)
		assert_equal 5, statuses.length
		statuses.each { |s| assert s.is_a?(String) }
	end

	test "medical_record_request factory should create bc request" do
		assert_difference('MedicalRecordRequest.count',1) {
			medical_record_request = FactoryBot.create(:medical_record_request)
			assert_match /Notes\d*/, medical_record_request.notes
		}
	end

	test "should return self for to_s if no study subject" do
		medical_record_request = MedicalRecordRequest.new
		assert_match /^#<MedicalRecordRequest:0x.+>$/, "#{medical_record_request}"
	end

	%w( active waitlist pending abstracted completed ).each do |status|

		test "should include #{status} medical record request in #{status} scope" do
			medical_record_request = FactoryBot.create(:medical_record_request,
				:status => status )
			medical_record_requests = MedicalRecordRequest.send( status )
			assert medical_record_requests.include?( medical_record_request )
		end

	end

	test "should include nil medical record request in incomplete scope" do
		medical_record_request = FactoryBot.create(:medical_record_request,
			:status => nil )
		medical_record_requests = MedicalRecordRequest.incomplete
		assert medical_record_requests.include?( medical_record_request )
	end

	test "should NOT include nil medical record request in complete scope" do
		medical_record_request = FactoryBot.create(:medical_record_request,
			:status => nil )
		medical_record_requests = MedicalRecordRequest.complete
		assert !medical_record_requests.include?( medical_record_request )
	end

	%w( active waitlist abstracted pending ).each do |status|

		test "should include #{status} medical record request in incomplete scope" do
			medical_record_request = FactoryBot.create(:medical_record_request,
				:status => status )
			medical_record_requests = MedicalRecordRequest.incomplete
			assert medical_record_requests.include?( medical_record_request )
		end

		test "should NOT include #{status} medical record request in complete scope" do
			medical_record_request = FactoryBot.create(:medical_record_request,
				:status => status )
			medical_record_requests = MedicalRecordRequest.complete
			assert !medical_record_requests.include?( medical_record_request )
		end

	end

	%w( completed ).each do |status|

		test "should include #{status} medical record request in complete scope" do
			medical_record_request = FactoryBot.create(:medical_record_request,
				:status => status )
			medical_record_requests = MedicalRecordRequest.complete
			assert medical_record_requests.include?( medical_record_request )
		end

		test "should NOT include #{status} medical record request in incomplete scope" do
			medical_record_request = FactoryBot.create(:medical_record_request,
				:status => status )
			medical_record_requests = MedicalRecordRequest.incomplete
			assert !medical_record_requests.include?( medical_record_request )
		end

	end

	test "should return study subject's studyid for to_s if study subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('MedicalRecordRequest.count',1) {
			study_subject = FactoryBot.create(:complete_case_study_subject)
			medical_record_request = FactoryBot.create(:medical_record_request)
			study_subject.medical_record_requests << medical_record_request
			assert_equal study_subject.studyid, "#{medical_record_request}"
		} }
	end

	test "should return medical_record_requests with status blank" do
		medical_record_request = FactoryBot.create(:medical_record_request)
		assert medical_record_request.status.blank?
		assert MedicalRecordRequest.with_status().include?(medical_record_request)
	end

	test "should return medical_record_requests with status bogus" do
		blank_medical_record_request = FactoryBot.create(:medical_record_request)
		assert blank_medical_record_request.status.blank?
		medical_record_request = FactoryBot.create(:medical_record_request)
		assert  medical_record_request.status.blank?
		medical_record_requests = MedicalRecordRequest.with_status('bogus')
		assert !medical_record_requests.include?(medical_record_request)
		assert !medical_record_requests.include?(blank_medical_record_request)
	end

	MedicalRecordRequest.statuses.each do |status|
		test "should return medical_record_requests with status #{status}" do
			blank_medical_record_request = FactoryBot.create(:medical_record_request)
			assert blank_medical_record_request.status.blank?
			medical_record_request = FactoryBot.create(:medical_record_request, :status => status)
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
