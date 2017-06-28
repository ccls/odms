require 'test_helper'

class CandidateControlTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to( :study_subject )
	assert_should_belong_to( :birth_datum )

	attributes = %w( assigned_on related_patid )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )

	assert_should_require_attribute_length( :related_patid, :is => 4 )
	assert_should_require_attribute_length( 
		:rejection_reason,
			:maximum => 250 )
	assert_should_require_attributes_not_nil( :reject_candidate )

	test "candidate_control factory should create candidate control" do
		assert_difference('CandidateControl.count',1) {
			candidate_control = FactoryGirl.create(:candidate_control)
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

	test "should return join of birth_datums name" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:first_name  => "John",
			:middle_name => "Michael",
			:last_name   => "Smith" )
		assert_equal 'John Michael Smith', birth_datum.candidate_control.full_name 
	end

	test "should return join of birth_datums name with blank middle name" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:first_name  => "John",
			:middle_name => "",
			:last_name   => "Smith" )
		assert_equal 'John Smith', birth_datum.candidate_control.full_name 
	end

	test "should return join of birth_datums mothers name" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:mother_first_name  => "Jane",
			:mother_middle_name => "Anne",
			:mother_maiden_name => "Smith" )
		assert_equal 'Jane Anne Smith', birth_datum.candidate_control.mother_full_name 
	end

	test "should return join of birth_datums mothers name with blank mothers middle name" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:mother_first_name  => "Jane",
			:mother_middle_name => "",
			:mother_maiden_name => "Smith" )
		assert_equal 'Jane Smith', birth_datum.candidate_control.mother_full_name 
	end

	################################################################################
	#
	#	BEGIN: MANY subject creation tests
	#

	test "should NOT create study_subjects from attributes if invalid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		StudySubject.any_instance.stubs(:valid?).returns(false)
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
		candidate_control.reload
		assert_nil candidate_control.assigned_on
		assert_nil candidate_control.study_subject_id
	end

	test "should NOT create study_subjects from attributes missing sex" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:sex => nil )
		candidate_control = birth_datum.candidate_control
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
		candidate_control.reload	# ensure that it is saved in the db!
		assert_nil candidate_control.assigned_on
		assert_nil candidate_control.study_subject_id
	end

	test "should NOT create study_subjects from attributes missing dob" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:dob => nil )
		candidate_control = birth_datum.candidate_control
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
		candidate_control.reload	# ensure that it is saved in the db!
		assert_nil candidate_control.assigned_on
		assert_nil candidate_control.study_subject_id
	end

	test "should create study_subjects from attributes missing first_name" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:first_name => nil )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		candidate_control.reload	# ensure that it is saved in the db!
		assert_not_nil candidate_control.assigned_on
		assert_not_nil candidate_control.study_subject_id
		assert_nil candidate_control.study_subject.first_name
	end

	test "should create study_subjects from attributes missing last_name" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:last_name => nil )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		candidate_control.reload	# ensure that it is saved in the db!
		assert_not_nil candidate_control.assigned_on
		assert_not_nil candidate_control.study_subject_id
		assert_nil candidate_control.study_subject.last_name
	end

	test "should create study_subjects from attributes" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		candidate_control.reload	# ensure that it is saved in the db!
		assert_not_nil candidate_control.assigned_on
		assert_not_nil candidate_control.study_subject_id
	end

	test "should set birth datum study subject id on study subject creation" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		candidate_control.reload	# ensure that it is saved in the db!
		assert_not_nil candidate_control.birth_datum
		assert_not_nil candidate_control.birth_datum.study_subject_id
		assert_equal   candidate_control.birth_datum.study_subject_id,
			candidate_control.study_subject_id
	end

	test "should create study_subjects and set is_matched" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		assert_nil case_study_subject.is_matched
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
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert !candidate_control.study_subject.enrollments.empty?
		assert_equal [Project['ccls']],
			candidate_control.study_subject.enrollments.collect(&:project)
	end

	test "should create control from attributes without patient" do
		case_study_subject = create_case_study_subject(
			:icf_master_id => 'CASE4BIRT')
		assert_nil case_study_subject.patient
		birth_datum = FactoryGirl.create(:control_birth_datum, 
			:master_id => case_study_subject.icf_master_id)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_nil candidate_control.study_subject.reference_date
	end

	test "should create control from attributes and copy case patid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_not_nil control_subject.patid
		assert_equal   control_subject.patid, case_study_subject.patid
	end

	test "should create control from attributes and copy do_not_use_state_registrar_no" do
		attribute = 'fake number'
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:do_not_use_state_registrar_no => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.do_not_use_state_registrar_no
		assert_equal attribute, control_subject.do_not_use_state_registrar_no
	end

	test "should create control from attributes and copy do_not_use_local_registrar_no" do
		attribute = 'fake number'
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:do_not_use_local_registrar_no => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.do_not_use_local_registrar_no
		assert_equal attribute, control_subject.do_not_use_local_registrar_no
	end

	test "should create control from attributes and copy sex" do
		attribute = 'DK'
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:sex => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.sex
		assert_equal attribute, control_subject.sex
	end

	test "should create control from attributes and copy birth_type" do
		attribute = 'xyz'
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:birth_type => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.birth_type
		assert_equal attribute, control_subject.birth_type
	end

	test "should create control from attributes and copy mother_yrs_educ" do
		attribute = 7
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:mother_yrs_educ => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.mother_yrs_educ
		assert_equal attribute, control_subject.mother_yrs_educ
	end

	test "should create control from attributes and copy father_yrs_educ" do
		attribute = 7
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:father_yrs_educ => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.father_yrs_educ
		assert_equal attribute, control_subject.father_yrs_educ
	end

	%w( father_first_name father_middle_name father_last_name
			mother_first_name mother_middle_name mother_maiden_name
			first_name middle_name last_name ).each do |field|

		#	only works because the field names are the same in both models

		test "should create control from attributes and copy and namerize #{field}" do
			value = 'SOMENAME'
			case_study_subject, birth_datum = create_case_and_control_birth_datum(
				field => value )
			candidate_control = birth_datum.candidate_control
			create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
			control_subject = candidate_control.study_subject
			assert_equal value,          candidate_control.send(field)
			assert_equal value.namerize, control_subject.send(field)
		end

	end

	test "should create control from attributes and copy dob" do
		attribute = Date.parse('Dec 5, 1971')
		case_study_subject, birth_datum = create_case_and_control_birth_datum(
			:dob => attribute )
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_equal attribute, candidate_control.dob
		assert_equal attribute, control_subject.dob
	end

	test "should create control from attributes with patient and copy case admit_date" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		assert_not_nil case_study_subject.patient
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		control_subject = candidate_control.study_subject
		assert_not_nil control_subject.reference_date
		assert_equal   control_subject.reference_date, case_study_subject.patient.admit_date
	end

	test "should create control from attributes and add subjectid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.subjectid
		assert_equal   candidate_control.study_subject.subjectid.length, 6
	end

	test "should create control from attributes and add familyid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.familyid
		assert_equal   candidate_control.study_subject.familyid.length, 6
	end

	test "should create control from attributes and subjectid should equal familyid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_equal   candidate_control.study_subject.familyid, 
										candidate_control.study_subject.subjectid
	end

	test "should create control from attributes and copy case matchingid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.matchingid
		assert_equal   candidate_control.study_subject.matchingid, 
									case_study_subject.matchingid
	end

	test "should create control from attributes and add orderno = 1" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.orderno
		#	As this will be the first control here ...
		assert_equal   candidate_control.study_subject.orderno, 1		
	end

	test "should create second control from attributes and add orderno = 2" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control_1 = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control_1,case_study_subject)
		birth_datum = FactoryGirl.create(:control_birth_datum, 
			:master_id => case_study_subject.icf_master_id)
		candidate_control_2 = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control_2,case_study_subject)
		assert_not_nil candidate_control_2.study_subject.orderno
		#	As this will be the second control here ...
		assert_equal   candidate_control_2.study_subject.orderno, 2		
	end

	test "should create control from attributes and add studyid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.studyid		
		assert_match /\d{4}-\d-\d/, candidate_control.study_subject.studyid
	end

	#	icf_master_id isn't required as may not have any
	test "should create control from attributes and add icf_master_id if any" do
		case_study_subject = create_complete_case_study_subject_with_icf_master_id
		imi = FactoryGirl.create(:icf_master_id,:icf_master_id => '123456789')
		birth_datum = FactoryGirl.create(:control_birth_datum, 
			:master_id => case_study_subject.icf_master_id)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.icf_master_id
		assert_equal   candidate_control.study_subject.icf_master_id, '123456789'
		assert_not_nil imi.reload.study_subject
		assert_equal   imi.study_subject, candidate_control.study_subject
		assert_not_nil imi.assigned_on
		assert_equal   imi.assigned_on, Date.current
	end

	test "should create mother from attributes" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.mother
		mother = candidate_control.study_subject.mother
		assert_nil mother.case_control_type
		assert_nil mother.orderno
	end

	test "should create mother from attributes and NOT copy case patid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.mother
		assert_nil mother.patid
	end

	test "should create mother from attributes with patient and copy case admit_date" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.reload.mother
		assert_not_nil mother.reference_date
		assert_equal   mother.reference_date, case_study_subject.patient.admit_date
	end

	test "should create mother from attributes and copy case matchingid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.mother
		assert_not_nil mother.matchingid
		assert_equal   mother.matchingid, 
									case_study_subject.matchingid
	end

	test "should create mother from attributes and copy child familyid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		mother = candidate_control.study_subject.mother
		assert_not_nil mother.familyid
		assert_equal candidate_control.study_subject.familyid, 
										mother.familyid
	end

	#	icf_master_id isn't required as may not have any
	test "should create mother from attributes and add icf_master_id if any" do
		case_study_subject = create_complete_case_study_subject_with_icf_master_id
		child_imi = FactoryGirl.create(:icf_master_id,:icf_master_id => 'child')
		mother_imi = FactoryGirl.create(:icf_master_id,:icf_master_id => 'mother')
		birth_datum = FactoryGirl.create(:control_birth_datum, 
			:master_id => case_study_subject.icf_master_id)
		candidate_control = birth_datum.candidate_control
		create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		assert_not_nil candidate_control.study_subject.icf_master_id
		assert_equal   candidate_control.study_subject.icf_master_id, 'child'
		assert_not_nil candidate_control.study_subject.mother.icf_master_id
		assert_equal   candidate_control.study_subject.mother.icf_master_id, 'mother'
		assert_not_nil child_imi.reload.study_subject
		assert_equal   child_imi.study_subject, candidate_control.study_subject
		assert_not_nil child_imi.assigned_on
		assert_equal   child_imi.assigned_on, Date.current
		assert_not_nil mother_imi.reload.study_subject
		assert_equal   mother_imi.study_subject, candidate_control.study_subject.mother
		assert_not_nil mother_imi.assigned_on
		assert_equal   mother_imi.assigned_on, Date.current
	end

	test "create study subject should create address from birth datum record" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum_with_address
		candidate_control = birth_datum.candidate_control
		assert_difference('Address.count',1){
			create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		}
	end

	test "create study subject should create event if address from birth datum record is invalid" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum_with_address
		candidate_control = birth_datum.candidate_control
		Address.any_instance.stubs(:valid?).returns(false)
		assert_difference("OperationalEvent.where(" <<
			":operational_event_type_id => #{OperationalEventType['bc_received'].id}).count",1) {
		assert_difference('Address.count',0){
			create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		} }
	end

	test "create study subject should create event if address from birth datum record fails save" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum_with_address
		candidate_control = birth_datum.candidate_control
		Address.any_instance.stubs(:create_or_update).returns(false)
		assert_difference("OperationalEvent.where(" <<
			":operational_event_type_id => #{OperationalEventType['bc_received'].id}).count",1) {
		assert_difference('Address.count',0){
			create_study_subjects_for_candidate_control(candidate_control,case_study_subject)
		} }
	end


	test "should rollback study subject creation of icf_master_id save fails" do
		case_study_subject = create_complete_case_study_subject_with_icf_master_id
		FactoryGirl.create(:icf_master_id,:icf_master_id => '123456789')
		birth_datum = FactoryGirl.create(:control_birth_datum, 
			:master_id => case_study_subject.icf_master_id)
		candidate_control = birth_datum.candidate_control
		assert_not_nil IcfMasterId.next_unused
		IcfMasterId.any_instance.stubs(:save!
			).raises(ActiveRecord::RecordNotSaved.new('Fake'))
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	test "should rollback if create_mother raises error" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		StudySubject.any_instance.stubs(:create_mother
			).raises(ActiveRecord::RecordNotSaved.new('Fake'))
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	test "should rollback if assign_icf_master_id raises error" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
		candidate_control = birth_datum.candidate_control
		StudySubject.any_instance.stubs(:assign_icf_master_id
			).raises(ActiveRecord::RecordNotSaved.new('Fake'))
		assert_difference('Enrollment.count',0) {
		assert_difference('StudySubject.count',0) {
		assert_raises(ActiveRecord::RecordNotSaved){
			candidate_control.create_study_subjects(case_study_subject)
		} } }
	end

	test "should rollback if create_study_subjects raises error" do
		case_study_subject, birth_datum = create_case_and_control_birth_datum
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



	test "case_study_subject_birth_state_CA should return true if case subject birth_state CA" do
		case_subject = FactoryGirl.create(:case_study_subject, :birth_state => 'CA')
		assert_not_nil case_subject.birth_state
		candidate_control = CandidateControl.new(:related_patid => case_subject.patid)
		assert candidate_control.case_study_subject_birth_state_CA?
	end

	test "case_study_subject_birth_state_CA should return false if case subject birth_state NOT CA" do
		case_subject = FactoryGirl.create(:case_study_subject, :birth_state => 'AZ')
		assert_not_nil case_subject.birth_state
		candidate_control = CandidateControl.new(:related_patid => case_subject.patid)
		assert !candidate_control.case_study_subject_birth_state_CA?
	end

	test "case_study_subject_birth_state_CA should return false if case subject nil" do
		candidate_control = CandidateControl.new(:related_patid => nil)
		assert !candidate_control.case_study_subject_birth_state_CA?
	end

	test "case_study_subject should return the case with related patid" do
		case_subject = FactoryGirl.create(:case_study_subject)
		assert_not_nil case_subject.patid
		candidate_control = CandidateControl.new(:related_patid => case_subject.patid)
		assert_equal case_subject, candidate_control.case_study_subject
	end

	test "case_study_subject should return nil with blank related patid" do
		candidate_control = CandidateControl.new(:related_patid => nil)
		assert_nil candidate_control.case_study_subject
	end

protected

	def create_study_subjects_for_candidate_control(candidate,case_subject)
		assert_difference('Enrollment.count',2) {	#	both get auto-created ccls enrollment
		assert_difference('StudySubject.count',2) {
			candidate.create_study_subjects(case_subject)
		} }
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_candidate_control

	def create_complete_case_study_subject_with_icf_master_id
		study_subject = FactoryGirl.create(:complete_case_study_subject,
			:icf_master_id => 'UCASE4BIR')
		assert_not_nil study_subject.icf_master_id
		assert_equal 'UCASE4BIR', study_subject.icf_master_id
		study_subject
	end

	def create_case_and_control_birth_datum_with_address(options={})
		create_case_and_control_birth_datum({
			:mother_residence_line_1 => '1995 UNIVERSITY AVE #460',
			:mother_residence_city   => 'BERKELEY',
			:mother_residence_county => 'ALAMEDA',
			:mother_residence_state  => 'CA',
			:mother_residence_zip    => '94704'
		}.merge(options))
	end

	def create_case_and_control_birth_datum(options={})
		case_study_subject = create_complete_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,{
			:master_id => case_study_subject.icf_master_id
		}.merge(options) )
		return case_study_subject, birth_datum
	end

end
