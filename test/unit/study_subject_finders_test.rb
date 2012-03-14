require 'test_helper'

#	This is just a collection of identifier related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectFindersTest < ActiveSupport::TestCase

###################################################
#
#	BEGIN find_all_by_studyid_or_icf_master_id
#
	test "should find by studyid or icf_master_id with studyid" do
		study_subject1 = Factory(:case_study_subject)
		study_subject2 = Factory(:case_study_subject)
		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
			study_subject1.studyid, nil )
		assert  study_subjects.include?(study_subject1)
		assert !study_subjects.include?(study_subject2)
	end

	test "should find by studyid or icf_master_id with case studyid" do
		subject = Factory(:complete_case_study_subject)
		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
			subject.studyid, nil )
		assert study_subjects.include?(subject)
	end

	test "should find by studyid or icf_master_id with case icf_master_id" do
		subject = Factory(:complete_case_study_subject)
		Factory(:icf_master_id, :icf_master_id => '123456789' )
		subject.assign_icf_master_id
		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
			nil, subject.icf_master_id )
		assert study_subjects.include?(subject)
	end

	test "should find by studyid or icf_master_id with control studyid" do
		subject = Factory(:complete_control_study_subject,
			:patid => '1234', :case_control_type => 'X', :orderno => 9)
		assert_equal subject.patid, '1234'
		assert_equal subject.case_control_type, 'X'
		assert_equal subject.orderno, 9
		assert_equal subject.studyid, '1234-X-9'
		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
			subject.studyid, nil )
		assert study_subjects.include?(subject)
	end

	test "should find by studyid or icf_master_id with control icf_master_id" do
		subject = Factory(:complete_control_study_subject)
		Factory(:icf_master_id, :icf_master_id => '123456789' )
		subject.assign_icf_master_id
		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
			nil, subject.icf_master_id )
		assert study_subjects.include?(subject)
	end

#	Mothers won't have a studyid
#	test "should find by studyid or icf_master_id with mother studyid" do
#		subject = Factory(:complete_mother_study_subject)
#		puts subject.studyid
#		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
#			subject.studyid, nil )
#		assert study_subjects.include?(subject)
#	end

	test "should find by studyid or icf_master_id with mother icf_master_id" do
		subject = Factory(:complete_mother_study_subject)
		Factory(:icf_master_id, :icf_master_id => '123456789' )
		subject.assign_icf_master_id
		study_subjects = StudySubject.find_all_by_studyid_or_icf_master_id(
			nil, subject.icf_master_id )
		assert study_subjects.include?(subject)
	end

#	TODO what about both studyid and icf_master_id?

#
#	END find_all_by_studyid_or_icf_master_id
#
###################################################

###################################################
#
#	BEGIN find_case_by_patid
#

	test "should return case by patid" do
		Factory(:case_study_subject)	#	just another for noise
		study_subject = Factory(:case_study_subject)
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


end
