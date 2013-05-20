require 'test_helper'

class FollowUpTest < ActiveSupport::TestCase

	assert_should_create_default_object
#	assert_should_initially_belong_to( :section, :enrollment, :follow_up_type)
	assert_should_initially_belong_to( :enrollment, :follow_up_type)

	test "follow_up factory should create follow up" do
		assert_difference('FollowUp.count',1) {
			follow_up = FactoryGirl.create(:follow_up)
		}
	end

	test "follow_up factory should create follow up type" do
		assert_difference('FollowUpType.count',1) {
			follow_up = FactoryGirl.create(:follow_up)
			assert_not_nil follow_up.follow_up_type
		}
	end

#	test "follow_up factory should create section" do
#		assert_difference('Section.count',1) {
#			follow_up = FactoryGirl.create(:follow_up)
#			assert_not_nil follow_up.section
#		}
#	end

	test "follow_up factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			follow_up = FactoryGirl.create(:follow_up)
		}
	end

	test "follow_up factory should create 2 enrollments" do
		#	again, creates subject, which creates ccls enrollment
		assert_difference('Enrollment.count',2) {	
			follow_up = FactoryGirl.create(:follow_up)
			assert_not_nil follow_up.enrollment
		}
	end

	test "follow up factory should create enrollment in new non-ccls project" do
		follow_up = FactoryGirl.create(:follow_up)
		assert !follow_up.new_record?
		assert ( follow_up.enrollment.project_id != Project['ccls'].id )
	end

	test "follow up factory should create enrollment in ccls project" do
		follow_up = FactoryGirl.create(:follow_up)
		other_enrollments = follow_up.enrollment.study_subject.enrollments - [follow_up.enrollment]
		assert_equal other_enrollments.length, 1
		ccls_enrollment = other_enrollments.first
		assert ( ccls_enrollment.project_id == Project['ccls'].id )
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_follow_up

end
