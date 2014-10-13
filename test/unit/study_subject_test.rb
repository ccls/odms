require 'test_helper'

class StudySubjectTest < ActiveSupport::TestCase

	assert_should_accept_only_good_values( :sex,
		{ :good_values => %w( M F DK ),
			:bad_values  => 'X' })

	assert_should_accept_only_good_values( :mom_is_biomom, :dad_is_biodad,
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_accept_only_good_values( :hispanicity, :hispanicity_mex,
 		:mother_hispanicity_mex, :father_hispanicity_mex,
		{ :good_values => ( YNRDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_accept_only_good_values( :mother_hispanicity, :father_hispanicity,
		{ :good_values => ( YNORDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_create_default_object

#	Cannot include enrollments here due to the creation of one
#	during the creation of a study_subject
#	Should create custom check, but this is indirectly tested
#	in the creation of the enrollment so not really needed.
#		:enrollments,

	assert_should_have_many( :bc_requests, :medical_record_requests, :alternate_contacts )
	assert_should_have_one( :home_exposure_response )
#	assert_should_have_one( :birth_datum )
	assert_should_have_many( :birth_data )

	attributes = %w( accession_no 
		birth_type birth_year case_control_type dad_is_biodad died_on 
		familyid father_hispanicity
		father_hispanicity_mex other_father_race 
		father_yrs_educ gbid legacy_other_race
		other_guardian_relationship hispanicity hispanicity_mex
		idno_wiemels is_duplicate_of is_matched lab_no lab_no_wiemels 
		local_registrar_no matchingid mom_is_biomom 
		mother_hispanicity mother_hispanicity_mex 
		other_mother_race mother_yrs_educ phase
		reference_date related_case_childid related_childid ssn state_id_no 
		state_registrar_no subjectid vital_status subject_type )
#		state_registrar_no subjectid vital_status_code )

#	no familyid, childid, patid, studyid, matchingid, icf_master_id ???

	required = %w(  subject_type vital_status )	#	this was blank, may need to be, its complicated
	unique   = %w( state_id_no state_registrar_no local_registrar_no
		gbid lab_no_wiemels accession_no idno_wiemels 
		subjectid childid )

#	NOTE icf_master_id is not set, so unique test doesn't fail
#	NOTE studyid is not set, so unique test doesn't fail

	protected_attributes = %w( studyid studyid_nohyphen
		studyid_intonly_nohyphen subjectid familyid childid patid 
		matchingid case_control_type  
subject_type )	#	can I have subject_type here?
	assert_should_require( required )
	assert_should_require_unique( unique )
	assert_should_protect( protected_attributes )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes - protected_attributes )

	assert_requires_complete_date( :reference_date, :died_on )

	assert_should_require_attributes_not_nil( :do_not_contact, :sex )

	assert_should_require_attribute_length( 
		:other_guardian_relationship,
		:other_mother_race, :other_father_race,
		:state_id_no,
		:state_registrar_no,
		:local_registrar_no,
		:lab_no,
		:related_childid,
		:related_case_childid,
		:maximum => 250 )

	assert_should_require_attribute_length( :gbid, :maximum => 26 )
	assert_should_require_attribute_length( :lab_no_wiemels, :accession_no, 
		:maximum => 25 )
	assert_should_require_attribute_length( :childidwho, :idno_wiemels,
			:maximum => 10 )
	assert_should_require_attribute_length( :newid, :maximum => 6 )
	assert_should_require_attribute_length( :birth_year, :maximum => 4 )

	test "study_subject factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			study_subject = FactoryGirl.create(:study_subject)
			assert_not_nil study_subject.vital_status
			assert_not_nil study_subject.sex
		}
	end

	test "study_subject factory should create subject type" do
#		assert_difference('SubjectType.count',1) {
			study_subject = FactoryGirl.create(:study_subject)
			assert_not_nil study_subject.subject_type
#		}
	end

	test "case study_subject should create study subject" do
		assert_difference('StudySubject.count',1) {
			study_subject = FactoryGirl.create(:case_study_subject)
#			assert_equal study_subject.subject_type, SubjectType['Case']
			assert_equal study_subject.subject_type, 'Case'
		}
	end

	test "case study_subject should not create subject type" do
#		assert_difference('SubjectType.count',0) {
			study_subject = FactoryGirl.create(:case_study_subject)
#		}
	end

	test "control study_subject factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			study_subject = FactoryGirl.create(:control_study_subject)
#			assert_equal study_subject.subject_type, SubjectType['Control']
			assert_equal study_subject.subject_type, 'Control'
		}
	end

	test "control study_subject factory should not create subject type" do
#		assert_difference('SubjectType.count',0) {
			study_subject = FactoryGirl.create(:control_study_subject)
#		}
	end

	test "minimum_raf_form_attributes should create differing random dobs" do
		#	build a couple and check that they are not the same
		#	it is possible that this will occassionally fail
		dob1 = FactoryGirl.attributes_for(:minimum_raf_form_attributes)[:dob]
		dob2 = FactoryGirl.attributes_for(:minimum_raf_form_attributes)[:dob]
		assert dob1 != dob2, "Expected #{dob1} and #{dob2} to differ"
	end

	test "mother study_subject factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			s = FactoryGirl.create(:mother_study_subject)
#			assert_equal s.subject_type, SubjectType['Mother']
			assert_equal s.subject_type, 'Mother'
			assert_equal s.sex, 'F'
			assert_nil     s.studyid
			assert_not_nil s.studyid_to_s
			assert_equal 'n/a', s.studyid_to_s
		}
	end

	test "mother study_subject factory should not create subject type" do
#		assert_difference('SubjectType.count',0) {
			s = FactoryGirl.create(:mother_study_subject)
#		}
	end

	test "explicit Factory complete case study subject build test" do
		assert_difference('Patient.count',0) {
		assert_difference('StudySubject.count',0) {
			s = FactoryGirl.build(:complete_case_study_subject)
		} }
	end

	test "complete case study subject factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			s = FactoryGirl.create(:complete_case_study_subject)
#			assert_equal s.subject_type, SubjectType['Case']
			assert_equal s.subject_type, 'Case'
			assert_equal s.case_control_type, 'C'
			assert_equal s.orderno, 0
			assert_not_nil s.childid
			assert_not_nil s.patid
			assert_not_nil s.organization_id
			assert_not_nil s.studyid
			assert_not_nil s.studyid
			assert_match /\d{4}-C-0/, s.studyid
#	New sequencing make the value of this relatively unpredictable
#			assert_equal s.organization_id, Hospital.first.organization_id
		}
	end

	test "complete case study subject factory should create patient" do
		assert_difference('Patient.count',1) {
			s = FactoryGirl.create(:complete_case_study_subject)
		}
	end

	test "complete waivered case study subject factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			s = FactoryGirl.create(:complete_waivered_case_study_subject)
#			assert_equal s.subject_type, SubjectType['Case']
			assert_equal s.subject_type, 'Case'
			assert_equal s.case_control_type, 'C'
			assert_equal s.orderno, 0
			assert_not_nil s.childid
			assert_not_nil s.patid
			assert_not_nil s.organization_id
		}
	end

	test "complete waivered case study subject factory should create waivered patient" do
		assert_difference('Patient.count',1) {
			s = FactoryGirl.create(:complete_waivered_case_study_subject)
			assert_not_nil s.organization_id
			assert s.organization.hospital.has_irb_waiver
		}
	end

	test "complete nonwaivered case study subject factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			s = FactoryGirl.create(:complete_nonwaivered_case_study_subject)
#			assert_equal s.subject_type, SubjectType['Case']
			assert_equal s.subject_type, 'Case'
			assert_equal s.case_control_type, 'C'
			assert_equal s.orderno, 0
			assert_not_nil s.childid
			assert_not_nil s.patid
			assert_not_nil s.organization_id
		}
	end

	test "complete nonwaivered case study subject factory should create nonwaivered patient" do
		assert_difference('Patient.count',1) {
			s = FactoryGirl.create(:complete_nonwaivered_case_study_subject)
			assert !s.organization.hospital.has_irb_waiver
		}
	end

	test "should require sex with custom message" do		#	No more custom message
		#	NOTE custom message
		study_subject = StudySubject.new( :sex => nil )
		assert !study_subject.valid?
		assert  study_subject.errors.include?(:sex)
		assert  study_subject.errors.matching?(:sex,"is not included in the list")
#		assert  study_subject.errors.matching?(:sex,"has not been chosen")
#		assert_match /Sex has not been chosen/, 
#			study_subject.errors.full_messages.to_sentence
#		assert_no_match /Sex can't be blank/i, 
#			study_subject.errors.full_messages.to_sentence
		assert_match /is not included in the list/i, 
			study_subject.errors.full_messages.to_sentence
	end

	test "create_control_study_subject should not create a subject type" do
#		assert_difference( 'SubjectType.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_control_study_subject
			assert !study_subject.is_case?
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} #}
	end

	test "create_case_study_subject should not create a subject type" do
#		assert_difference( 'SubjectType.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_case_study_subject
			assert study_subject.is_case?
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} #}
	end

	test "should create study_subject" do
#		assert_difference( 'SubjectType.count', 1 ){
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} #}
	end

	#
	#	The dependency relationships are left undefined for most models.
	#	Because of this, associated records are neither nullfied nor destroyed
	#	when the associated models is destroyed.
	#

	test "should NOT destroy bc_requests with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('BcRequest.count',1) {
			@study_subject = FactoryGirl.create(:study_subject)
			FactoryGirl.create(:bc_request, :study_subject => @study_subject)
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('BcRequest.count',0) {
			@study_subject.destroy
		} }
	end

	test "should NOT destroy home_exposure_response with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('HomeExposureResponse.count',1) {
			@study_subject = FactoryGirl.create(:home_exposure_response).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('HomeExposureResponse.count',0) {
			@study_subject.destroy
		} }
	end

	test "should not be case unless explicitly told" do
		study_subject = create_study_subject
		assert !study_subject.is_case?
	end

	test "should be case if explicitly told" do
		study_subject = FactoryGirl.create(:case_study_subject)
		assert study_subject.is_case?
	end

	test "should return concat of 3 fields as to_s" do
		study_subject = create_study_subject
		#	[childid,'(',studyid,full_name,')'].compact.join(' ')
		assert_equal "#{study_subject}",
			[study_subject.childid,'(',study_subject.studyid,study_subject.full_name,')'].compact.join(' ')
	end

	test "should return nil for next_control_orderno for control" do
		study_subject = create_complete_control_study_subject
		assert study_subject.is_control?
		assert_equal nil, study_subject.next_control_orderno
	end

	test "should return nil for next_control_orderno for mother" do
		study_subject = create_complete_mother_study_subject
		assert study_subject.is_mother?
		assert_equal nil, study_subject.next_control_orderno
	end

	test "should return 1 for next_control_orderno for case with no controls" do
		case_study_subject = create_case_study_subject
		assert_equal 1, case_study_subject.next_control_orderno
	end

	test "should return 2 for next_control_orderno for case with one control" do
		case_study_subject = create_case_study_subject
		assert_equal 1, case_study_subject.next_control_orderno
		control = create_control_study_subject(
			:matchingid => case_study_subject.subjectid,
			:case_control_type => '6',	#	<- default used for next_control_orderno
			:orderno    => case_study_subject.next_control_orderno )
		assert_equal 2, case_study_subject.next_control_orderno
	end

	test "should create mother when isn't one" do
		study_subject = create_complete_control_study_subject
		assert_nil study_subject.mother
		assert_difference('StudySubject.count',1) {
			@mother = study_subject.create_mother
		}
		assert_equal @mother, study_subject.mother
	end

	test "should copy mothers names when create mother for case" do
		study_subject = create_complete_case_study_subject(
			:mother_first_name  => 'First',
			:mother_middle_name => 'Middle',
			:mother_last_name   => 'Last',
			:mother_maiden_name => 'Maiden')
		assert_nil study_subject.reload.mother
		assert_difference('StudySubject.count',1) {
			@mother = study_subject.create_mother
			assert_equal @mother.first_name,  'First'
			assert_equal @mother.middle_name, 'Middle'
			assert_equal @mother.last_name,   'Last'
			assert_equal @mother.maiden_name, 'Maiden'
			assert_equal @mother.first_name,  study_subject.mother_first_name
			assert_equal @mother.middle_name, study_subject.mother_middle_name
			assert_equal @mother.last_name,   study_subject.mother_last_name
			assert_equal @mother.maiden_name, study_subject.mother_maiden_name
		}
		assert_equal @mother, study_subject.mother
	end

	test "should copy mothers names when create mother for control" do
		study_subject = create_complete_control_study_subject(
			:mother_first_name  => 'First',
			:mother_middle_name => 'Middle',
			:mother_last_name   => 'Last',
			:mother_maiden_name => 'Maiden')
		assert_nil study_subject.reload.mother
		assert_difference('StudySubject.count',1) {
			@mother = study_subject.create_mother
			assert_equal @mother.first_name,  'First'
			assert_equal @mother.middle_name, 'Middle'
			assert_equal @mother.last_name,   'Last'
			assert_equal @mother.maiden_name, 'Maiden'
			assert_equal @mother.first_name,  study_subject.mother_first_name
			assert_equal @mother.middle_name, study_subject.mother_middle_name
			assert_equal @mother.last_name,   study_subject.mother_last_name
			assert_equal @mother.maiden_name, study_subject.mother_maiden_name
		}
		assert_equal @mother, study_subject.mother
	end

	test "should copy mother_hispanicity when create mother for case" do
		study_subject = create_complete_case_study_subject(
			:mother_hispanicity => YNRDK[:yes])
		assert_equal study_subject.mother_hispanicity, YNRDK[:yes]
		assert_nil study_subject.reload.mother
		assert_difference('StudySubject.count',1) {
			@mother = study_subject.create_mother
			assert_equal @mother.hispanicity, YNRDK[:yes]
		}
		assert_equal @mother, study_subject.mother
	end

	test "should copy mother_hispanicity when create mother for control" do
		study_subject = create_complete_control_study_subject(
			:mother_hispanicity => YNRDK[:yes])
		assert_equal study_subject.mother_hispanicity, YNRDK[:yes]
		assert_nil study_subject.reload.mother
		assert_difference('StudySubject.count',1) {
			@mother = study_subject.create_mother
			assert_equal @mother.hispanicity, YNRDK[:yes]
		}
		assert_equal @mother, study_subject.mother
	end

	test "should not create mother when one exists" do
		study_subject = create_complete_control_study_subject
		mother = study_subject.create_mother
		assert_difference('StudySubject.count',0) {
			@mother = study_subject.create_mother
		}
		assert_equal @mother, mother
	end

	test "should not create mother for mother" do
		study_subject = FactoryGirl.create(:complete_mother_study_subject)
		assert_nil study_subject.familyid
		assert_nil study_subject.mother
		assert_equal study_subject, study_subject.create_mother
	end

	test "should return appended child's childid if is mother" do
		study_subject = FactoryGirl.create(:complete_control_study_subject)
		mother = study_subject.create_mother
		assert_not_nil study_subject.childid
		assert_nil     mother.childid
		assert_not_nil mother.childid_to_s
		assert_equal "#{study_subject.childid} (mother)", mother.childid_to_s
	end

#
#	As control is created attached to a case, it would be passed
#		a patid and computed orderno.  Creating an identifier on its
#		own would create a partial studyid like '-1-' or something
#		as the only thing the factory would create would be a random
#		case control type.  It should never actually be nil.
#
#	test "should return nil for subjects without studyid" do
#		study_subject = create_identifier(
#			:patid   => '0123', :orderno => 7 ).study_subject.reload
#		assert_nil study_subject.studyid
#	end

	test "should return n/a for mother's studyid" do
		study_subject = FactoryGirl.create(:complete_control_study_subject)
		mother = study_subject.create_mother
		assert_nil          mother.studyid
		assert_equal 'n/a', mother.studyid_to_s
	end

	test "should set phase to 5" do
		study_subject = StudySubject.new
		assert_not_nil study_subject.phase
		assert_equal   study_subject.phase, 5
	end

	test "replicates should return empty when replication_id is blank" do
		study_subject = StudySubject.new
		assert study_subject.replicates.empty?
	end

	test "replicates should return empty when replication_id is not blank and subjects exist with replication_id" do
		s = FactoryGirl.create(:study_subject, :replication_id => 1)
		study_subject = StudySubject.new(:replication_id => s.replication_id)
		assert !study_subject.replicates.empty?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
