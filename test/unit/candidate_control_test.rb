require 'test_helper'

class CandidateControlTest < ActiveSupport::TestCase

	assert_should_accept_only_good_values( :mom_is_biomom, :dad_is_biodad,
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_create_default_object
	assert_should_belong_to( :study_subject )
	assert_should_protect( :study_subject_id, :study_subject )
	assert_should_belong_to( :birth_datum )
	assert_should_protect( :birth_datum_id, :birth_datum )

	attributes = %w( assigned_on dad_is_biodad mom_is_biomom related_patid )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :related_patid, :is => 4 )
	assert_should_require_attribute_length( 
		:rejection_reason,
			:maximum => 250 )
	assert_should_require_attributes_not_nil( :reject_candidate )

	test "explicit Factory candidate_control test" do
		assert_difference('CandidateControl.count',1) {
			candidate_control = Factory(:candidate_control)
			assert_not_nil candidate_control.reject_candidate
			assert !candidate_control.reject_candidate
		}
	end

	test "should require rejection_reason if reject_candidate is true" do
		candidate_control = CandidateControl.new(
			:reject_candidate => true,
			:rejection_reason => nil)
		assert !candidate_control.valid?
		assert candidate_control.errors.matching?(:rejection_reason, "can't be blank")
	end

	test "should not require rejection_reason if reject_candidate is false" do
		candidate_control = CandidateControl.new(
			:reject_candidate => false,
			:rejection_reason => nil)
		candidate_control.valid?
		assert !candidate_control.errors.include?(:rejection_reason)
	end


	################################################################################
	#
	#	BEGIN: MANY subject creation tests
	#

	test "should create study_subjects from attributes" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = Factory(:candidate_control,:birth_datum => birth_datum)
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		candidate_control.reload	# ensure that it is saved in the db!
		assert_not_nil candidate_control.assigned_on
		assert_not_nil candidate_control.study_subject_id
	end

	test "should create study_subjects and set is_matched" do
		case_study_subject = Factory(:complete_case_study_subject)
		assert_nil case_study_subject.is_matched
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		candidate_control.reload	# ensure that it is saved in the db!
		assert_not_nil candidate_control.study_subject_id
		assert_not_nil candidate_control.study_subject.is_matched
		assert candidate_control.study_subject.is_matched
		assert_not_nil case_study_subject.is_matched
		assert case_study_subject.is_matched
	end

	#	this enrollment is actually a callback in study_subject
	# now and is not explictly called.
	test "should create control with enrollment in ccls" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert !candidate_control.study_subject.enrollments.empty?
		assert_equal [Project['ccls']],
			candidate_control.study_subject.enrollments.collect(&:project)
	end

	test "should create control from attributes without patient" do
		case_study_subject = create_case_study_subject
		assert_nil case_study_subject.patient
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_nil candidate_control.study_subject.reference_date
	end

	test "should create control from attributes and copy case patid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_not_nil control_subject.patid
		assert_equal   control_subject.patid, case_study_subject.patid
	end

#	test "should create control from attributes and set hispanicity_id nil" do
#		case_study_subject = Factory(:complete_case_study_subject)
#		birth_datum = Factory(:birth_datum)
#		candidate_control = Factory(:candidate_control,:birth_datum => birth_datum)
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_nil control_subject.hispanicity_id
#	end
#
#	test "should create control from attributes and set hispanicity_id if father_hispanicity" do
#		case_study_subject = Factory(:complete_case_study_subject)
#		birth_datum = Factory(:birth_datum, :father_hispanicity_id => 1 )
#		candidate_control = Factory(:candidate_control,:birth_datum => birth_datum)
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_not_nil control_subject.hispanicity_id
#		assert_equal   control_subject.hispanicity_id, 1
#	end
#
#	test "should create control from attributes and set hispanicity_id if mother_hispanicity" do
#		case_study_subject = Factory(:complete_case_study_subject)
#		birth_datum = Factory(:birth_datum, :mother_hispanicity_id => 1 )
#		candidate_control = Factory(:candidate_control,:birth_datum => birth_datum)
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_not_nil control_subject.hispanicity_id
#		assert_equal   control_subject.hispanicity_id, 1
#	end

	test "should create control from attributes and copy state_registrar_no" do
		attribute = 'fake number'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :state_registrar_no => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.state_registrar_no
		assert_equal attribute, control_subject.state_registrar_no
	end

	test "should create control from attributes and copy local_registrar_no" do
		attribute = 'fake number'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :local_registrar_no => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.local_registrar_no
		assert_equal attribute, control_subject.local_registrar_no
	end

	test "should create control from attributes and copy sex" do
		attribute = 'DK'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :sex => attribute)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.sex
		assert_equal attribute, control_subject.sex
	end

#	test "should create control from attributes and copy mother_hispanicity_id" do
#		attribute = 999
#		case_study_subject = Factory(:complete_case_study_subject)
#		candidate_control = Factory(:candidate_control, :mother_hispanicity_id => attribute )
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_equal attribute, candidate_control.mother_hispanicity_id
#		assert_equal attribute, control_subject.mother_hispanicity_id
#	end
#
#	test "should create control from attributes and copy father_hispanicity_id" do
#		attribute = 999
#		case_study_subject = Factory(:complete_case_study_subject)
#		candidate_control = Factory(:candidate_control, :father_hispanicity_id => attribute )
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_equal attribute, candidate_control.father_hispanicity_id
#		assert_equal attribute, control_subject.father_hispanicity_id
#	end

	test "should create control from attributes and copy birth_type" do
		attribute = 'xyz'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :birth_type => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.birth_type
		assert_equal attribute, control_subject.birth_type
	end

	test "should create control from attributes and copy mother_yrs_educ" do
		attribute = 7
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :mother_yrs_educ => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.mother_yrs_educ
		assert_equal attribute, control_subject.mother_yrs_educ
	end

	test "should create control from attributes and copy father_yrs_educ" do
		attribute = 7
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :father_yrs_educ => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.father_yrs_educ
		assert_equal attribute, control_subject.father_yrs_educ
	end

#	test "should create control from attributes and copy birth_county" do
#		attribute = 'Somewhere'
#		case_study_subject = Factory(:complete_case_study_subject)
#		candidate_control = Factory(:candidate_control, :birth_county => attribute )
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_equal attribute, candidate_control.birth_county
#		assert_equal attribute, control_subject.birth_county
#	end

	test "should create control from attributes and copy first_name" do
		attribute = 'SomeName'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :first_name => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.first_name
		assert_equal attribute, control_subject.first_name
	end

	test "should create control from attributes and copy middle_name" do
		attribute = 'SomeName'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :middle_name => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.middle_name
		assert_equal attribute, control_subject.middle_name
	end

	test "should create control from attributes and copy last_name" do
		attribute = 'SomeName'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :last_name => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.last_name
		assert_equal attribute, control_subject.last_name
	end

	test "should create control from attributes and copy dob" do
		attribute = Date.parse('Dec 5, 1971')
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :dob => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.dob
		assert_equal attribute, control_subject.dob
	end

	test "should create control from attributes and copy mother_first_name" do
		attribute = 'SomeName'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :mother_first_name => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.mother_first_name
		assert_equal attribute, control_subject.mother_first_name
	end

	test "should create control from attributes and copy mother_middle_name" do
		attribute = 'SomeName'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :mother_middle_name => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.mother_middle_name
		assert_equal attribute, control_subject.mother_middle_name
	end

#	test "should create control from attributes and copy mother_last_name" do
#		attribute = 'SomeName'
#		case_study_subject = Factory(:complete_case_study_subject)
#		candidate_control = Factory(:candidate_control, :mother_last_name => attribute )
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_equal attribute, candidate_control.mother_last_name
#		assert_equal attribute, control_subject.mother_last_name
#	end

	test "should create control from attributes and copy mother_maiden_name" do
		attribute = 'SomeName'
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum, :mother_maiden_name => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.mother_maiden_name
		assert_equal attribute, control_subject.mother_maiden_name
	end

#	test "should create control from attributes and copy mother_race_id" do
#		attribute = 123
#		case_study_subject = Factory(:complete_case_study_subject)
#		candidate_control = Factory(:candidate_control, :mother_race_id => attribute )
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_equal attribute, candidate_control.mother_race_id
#		assert_equal attribute, control_subject.mother_race_id
#	end

#	test "should create control from attributes and copy father_race_id" do
#		attribute = 123
#		case_study_subject = Factory(:complete_case_study_subject)
#		candidate_control = Factory(:candidate_control, :father_race_id => attribute )
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		control_subject = candidate_control.study_subject
#		assert_equal attribute, candidate_control.father_race_id
#		assert_equal attribute, control_subject.father_race_id
#	end

	test "should create control from attributes and copy mom_is_biomom" do
		attribute = 999
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		candidate_control.update_attributes( :mom_is_biomom => attribute )
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.mom_is_biomom
		assert_equal attribute, control_subject.mom_is_biomom
	end

	test "should create control from attributes and copy dad_is_biodad" do
		attribute = 999
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		candidate_control.update_attributes( :dad_is_biodad => attribute )
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.dad_is_biodad
		assert_equal attribute, control_subject.dad_is_biodad
	end

#	test "should create control from attributes with patient" do
#		case_study_subject = Factory(:complete_case_study_subject)
##	unnecessary with complete case factory
##		create_patient_for_subject(case_study_subject)
#		candidate_control = Factory(:candidate_control)
#		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
#		assert_equal candidate_control.study_subject.reference_date,
#			case_study_subject.admit_date
#	end

	test "should create control from attributes with patient and copy case admit_date" do
		case_study_subject = Factory(:complete_case_study_subject)
		assert_not_nil case_study_subject.patient
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_not_nil control_subject.reference_date
		assert_equal   control_subject.reference_date, case_study_subject.patient.admit_date
	end

	test "should create control from attributes and add subjectid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.subjectid
		assert_equal   candidate_control.study_subject.subjectid.length, 6
	end

	test "should create control from attributes and add familyid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.familyid
		assert_equal   candidate_control.study_subject.familyid.length, 6
	end

	test "should create control from attributes and subjectid should equal familyid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_equal   candidate_control.study_subject.familyid, 
										candidate_control.study_subject.subjectid
	end

	test "should create control from attributes and copy case matchingid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.matchingid
		assert_equal   candidate_control.study_subject.matchingid, 
									case_study_subject.matchingid
	end

	test "should create control from attributes and add orderno = 1" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.orderno
		#	As this will be the first control here ...
		assert_equal   candidate_control.study_subject.orderno, 1		
	end

	test "should create second control from attributes and add orderno = 2" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control_1 = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control_1,case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control_2 = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control_2,case_study_subject)
		assert_not_nil candidate_control_2.study_subject.orderno
		#	As this will be the second control here ...
		assert_equal   candidate_control_2.study_subject.orderno, 2		
	end

	test "should create control from attributes and add studyid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.studyid		
		assert_match /\d{4}-\d-\d/, candidate_control.study_subject.studyid
	end

	#	icf_master_id isn't required as may not have any
	test "should create control from attributes and add icf_master_id if any" do
		imi = Factory(:icf_master_id,:icf_master_id => '123456789')
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.icf_master_id
		assert_equal   candidate_control.study_subject.icf_master_id, '123456789'
		assert_not_nil imi.reload.study_subject
		assert_equal   imi.study_subject, candidate_control.study_subject
		assert_not_nil imi.assigned_on
		assert_equal   imi.assigned_on, Date.today
	end

	test "should create mother from attributes" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.mother
		mother = candidate_control.study_subject.mother
		assert_nil mother.case_control_type
		assert_nil mother.orderno
	end

	test "should create mother from attributes and NOT copy case patid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.mother
		assert_nil mother.patid
	end

	test "should create mother from attributes with patient and copy case admit_date" do
		case_study_subject = Factory(:complete_case_study_subject)
		case_study_subject.reload
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.reload.mother
		assert_not_nil mother.reference_date
		assert_equal   mother.reference_date, case_study_subject.patient.admit_date
	end

	test "should create mother from attributes and copy case matchingid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.mother
		assert_not_nil mother.matchingid
		assert_equal   mother.matchingid, 
									case_study_subject.matchingid
	end

	test "should create mother from attributes and copy child familyid" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.mother
		assert_not_nil mother.familyid
		assert_equal candidate_control.study_subject.familyid, 
										mother.familyid
	end

	#	icf_master_id isn't required as may not have any
	test "should create mother from attributes and add icf_master_id if any" do
		child_imi = Factory(:icf_master_id,:icf_master_id => 'child')
		mother_imi = Factory(:icf_master_id,:icf_master_id => 'mother')
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.icf_master_id
		assert_equal   candidate_control.study_subject.icf_master_id, 'child'
		assert_not_nil candidate_control.study_subject.mother.icf_master_id
		assert_equal   candidate_control.study_subject.mother.icf_master_id, 'mother'
		assert_not_nil child_imi.reload.study_subject
		assert_equal   child_imi.study_subject, candidate_control.study_subject
		assert_not_nil child_imi.assigned_on
		assert_equal   child_imi.assigned_on, Date.today
		assert_not_nil mother_imi.reload.study_subject
		assert_equal   mother_imi.study_subject, candidate_control.study_subject.mother
		assert_not_nil mother_imi.assigned_on
		assert_equal   mother_imi.assigned_on, Date.today
	end

	test "should rollback study subject creation of icf_master_id save fails" do
		Factory(:icf_master_id,:icf_master_id => '123456789')
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		assert_not_nil IcfMasterId.next_unused
		IcfMasterId.any_instance.stubs(:save!
			).raises(ActiveRecord::RecordNotSaved)
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	test "should rollback if create_mother raises error" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		StudySubject.any_instance.stubs(:create_mother
			).raises(ActiveRecord::RecordNotSaved)
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	test "should rollback if assign_icf_master_id raises error" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		StudySubject.any_instance.stubs(:assign_icf_master_id
			).raises(ActiveRecord::RecordNotSaved)
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	test "should rollback if create_study_subject raises error" do
		case_study_subject = Factory(:complete_case_study_subject)
		birth_datum = Factory(:birth_datum)
		candidate_control = birth_datum.candidate_control
		StudySubject.any_instance.stubs(:create_or_update).returns(false)
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	#
	#	END: MANY subject creation tests
	#
	################################################################################

protected

	def create_study_subjects_for_candidate_control(candidate,case_subject)
		assert_difference('Enrollment.count',2) {	#	both get auto-created ccls enrollment
		assert_difference('StudySubject.count',2) {
			candidate.create_study_subjects(case_subject)
		} }
	end

#	def create_patient_for_subject(subject)
#		patient = Factory(:patient, :study_subject => subject,
#			:admit_date => 5.years.ago )
#		assert_not_nil patient.admit_date
#	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_candidate_control

end
