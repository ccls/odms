require 'test_helper'

class StudySubjectSubjectTypeTest < ActiveSupport::TestCase

	assert_should_protect( :subject_type_id, :model => 'StudySubject' )
	assert_should_initially_belong_to( :subject_type, :model => 'StudySubject' )

	test "should require subject_type" do
#	protected so block assignment needed
		study_subject = StudySubject.new{|s|s.subject_type = nil}
		assert !study_subject.valid?
		assert !study_subject.errors.include?(:subject_type)
		assert  study_subject.errors.matching?(:subject_type_id,"can't be blank")
	end

	test "should require valid subject_type" do
#	protected so block assignment needed
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

	test "case subject should return true for is_case?" do
		subject = Factory(:case_study_subject)
		assert subject.is_case?
	end

	test "case subject should return false for is_control?" do
		subject = Factory(:case_study_subject)
		assert !subject.is_control?
	end

	test "case subject should return false for is_mother?" do
		subject = Factory(:case_study_subject)
		assert !subject.is_mother?
	end

	test "case subject should return false for is_father?" do
		subject = Factory(:case_study_subject)
		assert !subject.is_father?
	end

	test "case subject should return false for is_twin?" do
		subject = Factory(:case_study_subject)
		assert !subject.is_twin?
	end

	test "case subject should return true for is_child?" do
		subject = Factory(:case_study_subject)
		assert subject.is_child?
	end

	test "control subject should return false for is_case?" do
		subject = Factory(:control_study_subject)
		assert !subject.is_case?
	end

	test "control subject should return true for is_control?" do
		subject = Factory(:control_study_subject)
		assert subject.is_control?
	end

	test "control subject should return false for is_mother?" do
		subject = Factory(:control_study_subject)
		assert !subject.is_mother?
	end

	test "control subject should return false for is_father?" do
		subject = Factory(:control_study_subject)
		assert !subject.is_father?
	end

	test "control subject should return false for is_twin?" do
		subject = Factory(:control_study_subject)
		assert !subject.is_twin?
	end

	test "control subject should return true for is_child?" do
		subject = Factory(:control_study_subject)
		assert subject.is_child?
	end

	test "mother subject should return false for is_case?" do
		subject = Factory(:mother_study_subject)
		assert !subject.is_case?
	end

	test "mother subject should return false for is_control?" do
		subject = Factory(:mother_study_subject)
		assert !subject.is_control?
	end

	test "mother subject should return true for is_mother?" do
		subject = Factory(:mother_study_subject)
		assert subject.is_mother?
	end

	test "mother subject should return false for is_father?" do
		subject = Factory(:mother_study_subject)
		assert !subject.is_father?
	end

	test "mother subject should return false for is_twin?" do
		subject = Factory(:mother_study_subject)
		assert !subject.is_twin?
	end

	test "mother subject should return false for is_child?" do
		subject = Factory(:mother_study_subject)
		assert !subject.is_child?
	end

	test "father subject should return false for is_case?" do
		subject = Factory(:father_study_subject)
		assert !subject.is_case?
	end

	test "father subject should return false for is_control?" do
		subject = Factory(:father_study_subject)
		assert !subject.is_control?
	end

	test "father subject should return false for is_mother?" do
		subject = Factory(:father_study_subject)
		assert !subject.is_mother?
	end

	test "father subject should return true for is_father?" do
		subject = Factory(:father_study_subject)
		assert subject.is_father?
	end

	test "father subject should return false for is_twin?" do
		subject = Factory(:father_study_subject)
		assert !subject.is_twin?
	end

	test "father subject should return false for is_child?" do
		subject = Factory(:father_study_subject)
		assert !subject.is_child?
	end

	test "twin subject should return false for is_case?" do
		subject = Factory(:twin_study_subject)
		assert !subject.is_case?
	end

	test "twin subject should return false for is_control?" do
		subject = Factory(:twin_study_subject)
		assert !subject.is_control?
	end

	test "twin subject should return false for is_mother?" do
		subject = Factory(:twin_study_subject)
		assert !subject.is_mother?
	end

	test "twin subject should return false for is_father?" do
		subject = Factory(:twin_study_subject)
		assert !subject.is_father?
	end

	test "twin subject should return true for is_twin?" do
		subject = Factory(:twin_study_subject)
		assert subject.is_twin?
	end

	test "twin subject should return false for is_child?" do
		subject = Factory(:twin_study_subject)
		assert !subject.is_child?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
