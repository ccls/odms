require 'test_helper'

#	This is just a collection of identifier related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectFindersTest < ActiveSupport::TestCase

###################################################
#
#	BEGIN find_case_by_patid
#

	test "should return case by patid" do
		Factory(:case_study_subject)	#	just another for noise
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.patid
		found_study_subject = StudySubject.find_case_by_patid(study_subject.patid)
		assert_not_nil found_study_subject
		assert_equal study_subject, found_study_subject
	end

	test "should return nothing if no case matching patid" do
		study_subject = Factory(:case_study_subject)
		found_study_subject = StudySubject.find_case_by_patid('0000')
		assert_nil found_study_subject
	end

#
#	END find_case_by_patid
#
###################################################

	test "should find cases" do
		case_subject    = Factory(:case_study_subject)
		control_subject = Factory(:control_study_subject)
		mother_subject  = Factory(:mother_study_subject)
		cases = StudySubject.cases
		assert  cases.include?(case_subject)
		assert !cases.include?(control_subject)
		assert !cases.include?(mother_subject)
	end

	test "should find controls" do
		case_subject    = Factory(:case_study_subject)
		control_subject = Factory(:control_study_subject)
		mother_subject  = Factory(:mother_study_subject)
		controls = StudySubject.controls
		assert !controls.include?(case_subject)
		assert  controls.include?(control_subject)
		assert !controls.include?(mother_subject)
	end

	test "should find mothers" do
		case_subject    = Factory(:case_study_subject)
		control_subject = Factory(:control_study_subject)
		mother_subject  = Factory(:mother_study_subject)
		mothers = StudySubject.mothers
		assert !mothers.include?(case_subject)
		assert !mothers.include?(control_subject)
		assert  mothers.include?(mother_subject)
	end

	test "should find children" do
		case_subject    = Factory(:case_study_subject)
		control_subject = Factory(:control_study_subject)
		mother_subject  = Factory(:mother_study_subject)
		children = StudySubject.children
		assert  children.include?(case_subject)
		assert  children.include?(control_subject)
		assert !children.include?(mother_subject)
	end

	test "should find with patid" do
		noise = Factory(:case_study_subject)
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.patid
		assert_equal study_subject.patid.length, 4
		with_patid = StudySubject.with_patid(study_subject.patid)
		assert  with_patid.include?(study_subject)
		assert !with_patid.include?(noise)
	end

	test "should find with familyid" do
		noise = Factory(:case_study_subject)
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.familyid
		assert_equal study_subject.familyid.length, 6
		with_familyid = StudySubject.with_familyid(study_subject.familyid)
		assert  with_familyid.include?(study_subject)
		assert !with_familyid.include?(noise)
	end

	test "should find with matchingid" do
		noise = Factory(:case_study_subject)
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.matchingid
		assert_equal study_subject.matchingid.length, 6
		with_matchingid = StudySubject.with_matchingid(study_subject.matchingid)
		assert  with_matchingid.include?(study_subject)
		assert !with_matchingid.include?(noise)
	end

	test "should find with subjectid" do
		noise = Factory(:case_study_subject)
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.subjectid
		assert_equal study_subject.subjectid.length, 6
		with_subjectid = StudySubject.with_subjectid(study_subject.subjectid)
		assert  with_subjectid.include?(study_subject)
		assert !with_subjectid.include?(noise)
	end

end
__END__

