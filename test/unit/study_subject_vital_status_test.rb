require 'test_helper'

class StudySubjectVitalStatusTest < ActiveSupport::TestCase

	assert_should_accept_only_good_values( :vital_status,
		{ :good_values => StudySubject.valid_vital_statuses,
			:bad_values  => "I'm not valid", :model => 'StudySubject' })

	test "should set default vital status to living" do
		study_subject = StudySubject.new
		assert_not_nil study_subject.vital_status
		assert_equal   study_subject.vital_status, 'Living'
	end

	test "is_living should return true for study subject with vital status living" do
		study_subject = StudySubject.new(:vital_status => 'Living')
		assert study_subject.is_living?
	end

	test "is_living should return false for study subject with vital status deceased" do
		study_subject = StudySubject.new(:vital_status => 'Deceased')
		assert !study_subject.is_living?
	end

	test "is_living should return false for study subject with vital status nil" do
		study_subject = StudySubject.new
		#	as this is set with ||= in after_initialize, must actually set to nil after that
		study_subject.vital_status = nil
		assert !study_subject.is_living?
	end

	test "is_deceased should return true for study subject with vital status deceased" do
		study_subject = StudySubject.new(:vital_status => 'Deceased')
		assert study_subject.is_deceased?
	end

	test "is_deceased should return false for study subject with vital status living" do
		study_subject = StudySubject.new(:vital_status => 'Living')
		assert !study_subject.is_deceased?
	end

	test "is_deceased should return false for study subject with vital status nil" do
		study_subject = StudySubject.new
		#	as this is set with ||= in after_initialize, must actually set to nil after that
		study_subject.vital_status = nil
		assert !study_subject.is_deceased?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
