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

	test "should return child if subject is mother of case" do
		study_subject = Factory(:complete_case_study_subject)
		mother = study_subject.create_mother
		assert_equal mother, study_subject.mother
		assert_equal mother.child, study_subject
	end

	test "should return child if subject is mother of control" do
		study_subject = Factory(:complete_control_study_subject)
		mother = study_subject.create_mother
		assert_equal mother, study_subject.mother
		assert_equal mother.child, study_subject
	end

	test "should return nil for child if is not mother" do
		study_subject = Factory(:complete_control_study_subject)
		assert_nil study_subject.child
	end

	test "should find case child if is mother and has familyid" do
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.familyid
		mother = study_subject.create_mother
		assert_equal study_subject, mother.child
	end

	test "should not find case child if familyid is blank" do
		study_subject = Factory(:case_study_subject)
		study_subject.update_attribute(:familyid, nil)
		assert_nil study_subject.reload.familyid
		mother = study_subject.create_mother
		assert_nil mother.child
	end

	test "should not find case child if is not mother" do
		study_subject = Factory(:case_study_subject)
		assert_nil study_subject.child
	end

	test "should find control child if is mother and has familyid" do
		study_subject = Factory(:control_study_subject)
		assert_not_nil study_subject.familyid
		mother = study_subject.create_mother
		assert_equal study_subject, mother.child
	end

	test "should not find control child if familyid is blank" do
		study_subject = Factory(:control_study_subject)
		study_subject.update_attribute(:familyid, nil)
		assert_nil study_subject.reload.familyid
		mother = study_subject.create_mother
		assert_nil mother.child
	end

	test "should not find control child if is not mother" do
		study_subject = Factory(:control_study_subject)
		assert_nil study_subject.child
	end

	test "should return nil for mother with nil familyid" do
		#	only a mother won't be assigned a familyid
		study_subject = Factory(:mother_study_subject)
		assert_nil study_subject.familyid
		assert_nil study_subject.mother
	end

	test "should return mother if is one" do
#	TODO maybe return nil instead of self?
		study_subject = Factory(:complete_control_study_subject)
		assert_nil study_subject.mother
		mother = study_subject.create_mother
		assert_not_nil study_subject.mother
		assert_equal mother, study_subject.mother
	end

	test "should find mother if has familyid" do
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.familyid
		mother = study_subject.create_mother
		assert_equal study_subject.mother, mother
	end

	test "should not find mother if familyid is blank" do
		study_subject = Factory(:case_study_subject)
		study_subject.update_attribute(:familyid, nil)
		assert_nil study_subject.reload.familyid
		mother = study_subject.create_mother
		assert_nil study_subject.mother
	end

#
#	family/familyid is for matching subject to family members
#
	test "should NOT include self in family for case" do
		study_subject = create_complete_case_study_subject
		assert study_subject.is_case?
		assert_equal 0, study_subject.family.length
	end

	test "should NOT include self in family for control" do
		study_subject = create_complete_control_study_subject
		assert study_subject.is_control?
		assert_equal 0, study_subject.family.length
	end

	test "should include mother in family for case" do
		study_subject = create_complete_case_study_subject
		assert study_subject.is_case?
		mother = study_subject.create_mother
		assert_equal study_subject.family.length, 1
		assert       study_subject.family.include?(mother)
	end

	test "should include mother in family for control" do
		study_subject = create_complete_control_study_subject
		assert study_subject.is_control?
		mother = study_subject.create_mother
		assert_equal study_subject.family.length, 1
		assert       study_subject.family.include?(mother)
	end

	test "should return nothing for null familyid for family" do
		#	only a mother won't be assigned a familyid
		study_subject = Factory(:mother_study_subject)
		assert_nil study_subject.familyid
		assert_equal study_subject.family.length, 0
	end

	test "should find all family if has familyid" do
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.familyid
		mother = study_subject.create_mother
		assert study_subject.family.include?(mother)
	end

	test "should not find all family if familyid is blank" do
		study_subject = Factory(:case_study_subject)
		study_subject.update_attribute(:familyid, nil)
		assert_nil study_subject.reload.familyid
		mother = study_subject.create_mother
		assert study_subject.family.empty?
	end

#
#	matching/matchingid is for matching cases and controls
#		This will also include case's family
#
	test "should NOT include self in matching for case" do
		study_subject = create_complete_case_study_subject
		assert study_subject.is_case?
		assert_equal 0, study_subject.matching.length
	end

	test "should NOT include self in matching for control" do
		study_subject = create_complete_control_study_subject
		assert study_subject.is_control?
		assert_equal 0, study_subject.matching.length
	end

	test "should include mother in matching for case" do
		study_subject = create_complete_case_study_subject
		assert study_subject.is_case?
		assert_not_nil study_subject.matchingid
		mother = study_subject.create_mother
		assert_equal study_subject.matching.length, 1
		assert       study_subject.matching.include?(mother)
	end

	test "should NOT include mother in matching for control" do
		study_subject = create_complete_control_study_subject
		assert study_subject.is_control?
		assert_nil study_subject.matchingid
		mother = study_subject.create_mother
		assert_equal 0, study_subject.matching.length
	end

	test "should return nothing for null matchingid for matching" do
		#	only case is auto-assigned a matchingid
		study_subject = Factory(:study_subject)
		assert_nil study_subject.matchingid
		assert_equal study_subject.matching.length, 0
	end

	test "should find all matching if has matchingid" do
		study_subject = Factory(:case_study_subject)
		assert_not_nil study_subject.matchingid
		mother = study_subject.create_mother
		assert study_subject.matching.include?(mother)
	end

	test "should not find all matching if matchingid is blank" do
		study_subject = Factory(:case_study_subject)
		study_subject.update_attribute(:matchingid, nil)
		assert_nil study_subject.reload.matchingid
		mother = study_subject.create_mother
		assert study_subject.matching.empty?
	end

	test "should get control subjects for case subject" do
		study_subject = create_complete_case_study_subject
		assert_equal [], study_subject.controls	#	aren't any controls, yet
		control = create_control_study_subject(
			:patid => study_subject.patid).reload
		assert_equal [control], study_subject.controls
	end

	test "should get other control subjects for control subject" do
		study_subject = create_complete_control_study_subject
		assert_equal [], study_subject.controls
		control = create_control_study_subject				
		#	both have nil patid so not particularly helpful 'patid = NULL' doesn't work
		assert_equal [], study_subject.controls
	end

	test "should find all controls if is case" do
		study_subject = Factory(:case_study_subject)
		assert study_subject.controls.empty?
		control = Factory(:control_study_subject,
			:patid => study_subject.patid)
		assert study_subject.controls.include?(control)
	end

	test "should not find all controls if is control" do
		study_subject = Factory(:control_study_subject)
		assert study_subject.controls.empty?
	end

	test "should not find all controls if is mother" do
		study_subject = Factory(:mother_study_subject)
		assert study_subject.controls.empty?
	end


	test "should return rejected controls for case subject" do
		study_subject = Factory(:complete_case_study_subject)
		assert study_subject.is_case?
		assert study_subject.rejected_controls.empty?
		candidate_control = create_rejected_candidate_control(
			:related_patid => study_subject.patid)
		assert_equal [candidate_control], study_subject.rejected_controls
	end

	test "should return rejected controls for control subject" do
		study_subject = Factory(:complete_control_study_subject)
		assert !study_subject.is_case?
		assert  study_subject.is_control?
		assert study_subject.rejected_controls.empty?
		candidate_control = create_rejected_candidate_control(
			:related_patid => study_subject.patid)
		assert_equal [], study_subject.rejected_controls
	end

end
__END__
