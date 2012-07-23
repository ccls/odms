require 'test_helper'

class StudySubjectVitalStatusTest < ActiveSupport::TestCase

	assert_should_initially_belong_to( :vital_status, :model => 'StudySubject' )

#	The factory sets the values AFTER after_initialize
#	so the defaults will be overwritten.
	test "should belong to vital_status" do
		study_subject = create_study_subject
		assert_not_nil study_subject.vital_status
		assert_not_nil study_subject.vital_status_id
		study_subject = create_study_subject(:vital_status => nil)
		study_subject.reload
		assert_nil study_subject.vital_status
		assert_nil study_subject.vital_status_id
		study_subject = create_study_subject(:vital_status_id => nil)
		study_subject.reload
		assert_nil study_subject.vital_status
		assert_nil study_subject.vital_status_id
		study_subject.vital_status = Factory(:vital_status)
		assert_not_nil study_subject.vital_status
	end

	test "should set default vital status to living" do
		study_subject = StudySubject.new
		assert_not_nil study_subject.vital_status_id
		assert_not_nil study_subject.vital_status
		assert_equal   study_subject.vital_status_id, VitalStatus['living'].id
		assert_equal   study_subject.vital_status, VitalStatus['living']
	end

	test "is_living should return true for study subject with vital status living" do
		study_subject = StudySubject.new(:vital_status_id => VitalStatus['living'].id)
		assert study_subject.is_living?
	end

	test "is_living should return false for study subject with vital status deceased" do
		study_subject = StudySubject.new(:vital_status_id => VitalStatus['deceased'].id)
		assert !study_subject.is_living?
	end

	test "is_living should return false for study subject with vital status nil" do
		study_subject = StudySubject.new
		#	as this is set with ||= in after_initialize, must actually set to nil after that
		study_subject.vital_status_id = nil
		assert !study_subject.is_living?
	end

	test "is_deceased should return true for study subject with vital status deceased" do
		study_subject = StudySubject.new(:vital_status_id => VitalStatus['deceased'].id)
		assert study_subject.is_deceased?
	end

	test "is_deceased should return false for study subject with vital status living" do
		study_subject = StudySubject.new(:vital_status_id => VitalStatus['living'].id)
		assert !study_subject.is_deceased?
	end

	test "is_deceased should return false for study subject with vital status nil" do
		study_subject = StudySubject.new
		#	as this is set with ||= in after_initialize, must actually set to nil after that
		study_subject.vital_status_id = nil
		assert !study_subject.is_deceased?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
