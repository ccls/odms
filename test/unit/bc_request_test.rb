require 'test_helper'

class BcRequestTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to( :study_subject )
	assert_should_protect( :study_subject_id, :study_subject )

	attributes = %w( is_found status )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :notes, :maximum => 65000 )

	assert_should_accept_only_good_values( :status,
		{ :good_values => BcRequest.statuses,
			:bad_values  => 'Funky' })

	test "statuses should return an array of strings" do
		statuses = BcRequest.statuses
		assert statuses.is_a?(Array)
		assert_equal 4, statuses.length
		statuses.each { |s| assert s.is_a?(String) }
	end

	test "bc_request factory should create bc request" do
		assert_difference('BcRequest.count',1) {
			bc_request = FactoryGirl.create(:bc_request)
			assert_match /Notes\d*/, bc_request.notes
		}
	end

	test "should return self for to_s if no study subject" do
		bc_request = BcRequest.new
		assert_match /^#<BcRequest:0x.+>$/, "#{bc_request}"
	end


	test "should include active bc request in active scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'active' )
		bc_requests = BcRequest.active
		assert bc_requests.include?( bc_request )
	end

	test "should include waitlist bc request in waitlist scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'waitlist' )
		bc_requests = BcRequest.waitlist
		assert bc_requests.include?( bc_request )
	end

	test "should include pending bc request in pending scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'pending' )
		bc_requests = BcRequest.pending
		assert bc_requests.include?( bc_request )
	end

	test "should include complete bc request in complete scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'complete' )
		bc_requests = BcRequest.complete
		assert bc_requests.include?( bc_request )
	end

	test "should include nil bc request in incomplete scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => nil )
		bc_requests = BcRequest.incomplete
		assert bc_requests.include?( bc_request )
	end

	test "should include active bc request in incomplete scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'active' )
		bc_requests = BcRequest.incomplete
		assert bc_requests.include?( bc_request )
	end

	test "should include waitlist bc request in incomplete scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'waitlist' )
		bc_requests = BcRequest.incomplete
		assert bc_requests.include?( bc_request )
	end

	test "should include pending bc request in incomplete scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'pending' )
		bc_requests = BcRequest.incomplete
		assert bc_requests.include?( bc_request )
	end

	test "should NOT include complete bc request in incomplete scope" do
		bc_request = FactoryGirl.create(:bc_request,
			:status => 'complete' )
		bc_requests = BcRequest.incomplete
		assert !bc_requests.include?( bc_request )
	end


	test "should return study subject's studyid for to_s if study subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('BcRequest.count',1) {
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			bc_request = FactoryGirl.create(:bc_request)
			study_subject.bc_requests << bc_request
			assert_equal study_subject.studyid, "#{bc_request}"
		} }
	end

	test "should return bc_requests with status blank" do
		bc_request = FactoryGirl.create(:bc_request)
		assert bc_request.status.blank?
		assert BcRequest.with_status().include?(bc_request)
	end

	test "should return bc_requests with status bogus" do
		blank_bc_request = FactoryGirl.create(:bc_request)
		assert blank_bc_request.status.blank?
		bc_request = FactoryGirl.create(:bc_request)
		assert  bc_request.status.blank?
		bc_requests = BcRequest.with_status('bogus')
		assert !bc_requests.include?(bc_request)
		assert !bc_requests.include?(blank_bc_request)
	end

	BcRequest.statuses.each do |status|
		test "should return bc_requests with status #{status}" do
			blank_bc_request = FactoryGirl.create(:bc_request)
			assert blank_bc_request.status.blank?
			bc_request = FactoryGirl.create(:bc_request, :status => status)
#			assert !bc_request.status.blank?
			assert bc_request.status.present?
			assert_equal status, bc_request.status
			bc_requests = BcRequest.with_status(status)
			assert  bc_requests.include?(bc_request)
			assert !bc_requests.include?(blank_bc_request)
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_bc_request

end
