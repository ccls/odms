require 'test_helper'

class StudySubjectSubjectTypeTest < ActiveSupport::TestCase

	assert_should_protect( :subject_type_id, :model => 'StudySubject' )
	assert_should_initially_belong_to( :subject_type, :model => 'StudySubject' )

	test "should require subject_type" do
#	protected
		study_subject = StudySubject.new{|s|s.subject_type = nil}
		assert !study_subject.valid?
		assert !study_subject.errors.include?(:subject_type)
		assert  study_subject.errors.matching?(:subject_type_id,"can't be blank")
	end

	test "should require valid subject_type" do
#	protected
		study_subject = StudySubject.new{|s|s.subject_type_id = 0}
		assert !study_subject.valid?
		assert !study_subject.errors.include?(:subject_type_id)
		assert  study_subject.errors.matching?(:subject_type,"can't be blank")
	end

	test "should return subject_type description for string" do
		study_subject = create_study_subject
		assert_equal study_subject.subject_type.description,
			"#{study_subject.subject_type}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
