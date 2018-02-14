require 'test_helper'

class BloodSpotRequestTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to( :study_subject )

	attributes = %w( is_found status )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )

	assert_should_require_attribute_length( :notes, :maximum => 65000 )

	assert_should_accept_only_good_values( :status,
		{ :good_values => BloodSpotRequest.statuses,
			:bad_values  => 'Funky' })

	test "statuses should return an array of strings" do
		statuses = BloodSpotRequest.statuses
		assert statuses.is_a?(Array)
		assert_equal 5, statuses.length
		statuses.each { |s| assert s.is_a?(String) }
	end

	test "blood_spot_request factory should create bc request" do
		assert_difference('BloodSpotRequest.count',1) {
			blood_spot_request = FactoryBot.create(:blood_spot_request)
			assert_match /Notes\d*/, blood_spot_request.notes
		}
	end

	test "should return self for to_s if no study subject" do
		blood_spot_request = BloodSpotRequest.new
		assert_match /^#<BloodSpotRequest:0x.+>$/, "#{blood_spot_request}"
	end


	%w( active waitlist pending unavailable completed ).each do |status|

		test "should include #{status} blood spot request in #{status} scope" do
			blood_spot_request = FactoryBot.create(:blood_spot_request,
				:status => status )
			blood_spot_requests = BloodSpotRequest.send(status)
			assert blood_spot_requests.include?( blood_spot_request )
		end

	end

	test "should include nil blood spot request in incomplete scope" do
		blood_spot_request = FactoryBot.create(:blood_spot_request,
			:status => nil )
		blood_spot_requests = BloodSpotRequest.incomplete
		assert blood_spot_requests.include?( blood_spot_request )
	end

	test "should NOT include nil blood spot request in complete scope" do
		blood_spot_request = FactoryBot.create(:blood_spot_request,
			:status => nil )
		blood_spot_requests = BloodSpotRequest.complete
		assert !blood_spot_requests.include?( blood_spot_request )
	end

	%w( active waitlist pending ).each do |status|

		test "should include #{status} blood spot request in incomplete scope" do
			blood_spot_request = FactoryBot.create(:blood_spot_request,
			:status => status )
			blood_spot_requests = BloodSpotRequest.incomplete
			assert blood_spot_requests.include?( blood_spot_request )
		end

		test "should NOT #{status} pending blood spot request in complete scope" do
			blood_spot_request = FactoryBot.create(:blood_spot_request,
				:status => status )
			blood_spot_requests = BloodSpotRequest.complete
			assert !blood_spot_requests.include?( blood_spot_request )
		end

	end

	%w( completed unavailable ).each do |status|

		test "should include #{status} blood spot request in complete scope" do
			blood_spot_request = FactoryBot.create(:blood_spot_request,
			:status => status )
			blood_spot_requests = BloodSpotRequest.complete
			assert blood_spot_requests.include?( blood_spot_request )
		end

		test "should NOT #{status} pending blood spot request in incomplete scope" do
			blood_spot_request = FactoryBot.create(:blood_spot_request,
				:status => status )
			blood_spot_requests = BloodSpotRequest.incomplete
			assert !blood_spot_requests.include?( blood_spot_request )
		end

	end

	test "should return study subjects studyid for to_s if study subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('BloodSpotRequest.count',1) {
			study_subject = FactoryBot.create(:complete_case_study_subject)
			blood_spot_request = FactoryBot.create(:blood_spot_request)
			study_subject.blood_spot_requests << blood_spot_request
			assert_equal study_subject.studyid, "#{blood_spot_request}"
		} }
	end

	test "should return blood_spot_requests with status blank" do
		blood_spot_request = FactoryBot.create(:blood_spot_request)
		assert blood_spot_request.status.blank?
		assert BloodSpotRequest.with_status().include?(blood_spot_request)
	end

	test "should return blood_spot_requests with status bogus" do
		blank_blood_spot_request = FactoryBot.create(:blood_spot_request)
		assert blank_blood_spot_request.status.blank?
		blood_spot_request = FactoryBot.create(:blood_spot_request)
		assert  blood_spot_request.status.blank?
		blood_spot_requests = BloodSpotRequest.with_status('bogus')
		assert !blood_spot_requests.include?(blood_spot_request)
		assert !blood_spot_requests.include?(blank_blood_spot_request)
	end

	BloodSpotRequest.statuses.each do |status|
		test "should return blood_spot_requests with status #{status}" do
			blank_blood_spot_request = FactoryBot.create(:blood_spot_request)
			assert blank_blood_spot_request.status.blank?
			blood_spot_request = FactoryBot.create(:blood_spot_request, :status => status)
			assert blood_spot_request.status.present?
			assert_equal status, blood_spot_request.status
			blood_spot_requests = BloodSpotRequest.with_status(status)
			assert  blood_spot_requests.include?(blood_spot_request)
			assert !blood_spot_requests.include?(blank_blood_spot_request)
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_blood_spot_request

end
