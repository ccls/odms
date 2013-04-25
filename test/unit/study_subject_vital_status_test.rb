require 'test_helper'

class StudySubjectVitalStatusTest < ActiveSupport::TestCase

	assert_should_accept_only_good_values( :vital_status,
		{ :good_values => ["Living", "Deceased", "Refused to State", "Don't Know"],
			:bad_values  => 'X', :model => 'StudySubject' })

#	assert_should_initially_belong_to( :vital_status, :model => 'StudySubject' )

#	The factory sets the values AFTER after_initialize
#	so the defaults will be overwritten.
#	test "should belong to vital_status" do
#		study_subject = create_study_subject
#		assert_not_nil study_subject.vital_status
#		assert_not_nil study_subject.vital_status_code
#		study_subject = create_study_subject(:vital_status => nil)
#		study_subject.reload
#		assert_nil study_subject.vital_status
#		assert_nil study_subject.vital_status_code
#		study_subject = create_study_subject(:vital_status_code => nil)
#		study_subject.reload
#		assert_nil study_subject.vital_status
#		assert_nil study_subject.vital_status_code
#		study_subject.vital_status = FactoryGirl.create(:vital_status)
#		assert_not_nil study_subject.vital_status
#	end

	test "should set default vital status to living" do
		study_subject = StudySubject.new
#		assert_not_nil study_subject.vital_status_code
		assert_not_nil study_subject.vital_status
#		assert_equal   study_subject.vital_status_code, VitalStatus['living'].code
#		assert_equal   study_subject.vital_status, VitalStatus['living']
		assert_equal   study_subject.vital_status, 'Living'
	end

	test "is_living should return true for study subject with vital status living" do
#		study_subject = StudySubject.new(:vital_status_code => VitalStatus['living'].code)
		study_subject = StudySubject.new(:vital_status => 'Living')
		assert study_subject.is_living?
	end

	test "is_living should return false for study subject with vital status deceased" do
#		study_subject = StudySubject.new(:vital_status_code => VitalStatus['deceased'].code)
		study_subject = StudySubject.new(:vital_status => 'Deceased')
		assert !study_subject.is_living?
	end

	test "is_living should return false for study subject with vital status nil" do
		study_subject = StudySubject.new
		#	as this is set with ||= in after_initialize, must actually set to nil after that
#		study_subject.vital_status_code = nil
		study_subject.vital_status = nil
		assert !study_subject.is_living?
	end

	test "is_deceased should return true for study subject with vital status deceased" do
#		study_subject = StudySubject.new(:vital_status_code => VitalStatus['deceased'].code)
		study_subject = StudySubject.new(:vital_status => 'Deceased')
		assert study_subject.is_deceased?
	end

	test "is_deceased should return false for study subject with vital status living" do
#		study_subject = StudySubject.new(:vital_status_code => VitalStatus['living'].code)
		study_subject = StudySubject.new(:vital_status => 'Living')
		assert !study_subject.is_deceased?
	end

	test "is_deceased should return false for study subject with vital status nil" do
		study_subject = StudySubject.new
		#	as this is set with ||= in after_initialize, must actually set to nil after that
#		study_subject.vital_status_code = nil
		study_subject.vital_status = nil
		assert !study_subject.is_deceased?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
