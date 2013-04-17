require 'test_helper'

class BirthDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )

	test "birth_datum factory should create birth datum" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert !birth_datum.new_record?
	end

	test "birth_datum factory should create odms exception" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /master_id, childid and subjectid blank/,
			birth_datum.odms_exceptions.first.to_s
	end

	test "birth_datum factory should NOT create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = FactoryGirl.create(:birth_datum)
		}
	end

	test "birth_datum factory should have dob" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "birth_datum factory should have sex" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "birth_datum factory should not have first name" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_nil birth_datum.first_name
	end

	test "birth_datum factory should not have last name" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_nil birth_datum.last_name
	end

	test "birth_datum factory should not have case control flag" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_nil birth_datum.case_control_flag
	end

	test "birth_datum factory should not have match confidence" do
		birth_datum = FactoryGirl.create(:birth_datum)
		assert_nil birth_datum.match_confidence
	end

	test "case_birth_datum factory should create birth datum" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert !birth_datum.new_record?
	end

	test "case_birth_datum factory should create odms exception" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /master_id, childid and subjectid blank/,
			birth_datum.odms_exceptions.first.to_s
	end

	test "case_birth_datum factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = FactoryGirl.create(:case_birth_datum)
		}
	end

	test "case_birth_datum factory should have dob" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "case_birth_datum factory should have sex" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "case_birth_datum factory should have case control flag" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_equal 'case', birth_datum.case_control_flag
	end

	test "case_birth_datum factory should have match confidence" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_equal 'definite', birth_datum.match_confidence
	end

	test "control_birth_datum factory should create birth datum" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert !birth_datum.new_record?
	end

	test "control_birth_datum factory should create odms exception" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /master_id, childid and subjectid blank/,
			birth_datum.odms_exceptions.first.to_s
	end

	test "control_birth_datum factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = FactoryGirl.create(:control_birth_datum)
		}
	end

	test "control_birth_datum factory should have dob" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "control_birth_datum factory should have sex" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "control_birth_datum factory should have case control flag" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert_equal  'control', birth_datum.case_control_flag
	end

	test "control_birth_datum factory should not have match confidence" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert_nil birth_datum.match_confidence
	end

	test "bogus_birth_datum factory should create birth datum" do
		birth_datum = FactoryGirl.create(:bogus_birth_datum)
		assert !birth_datum.new_record?
	end

	test "bogus_birth_datum factory should create odms exception" do
		birth_datum = FactoryGirl.create(:bogus_birth_datum)
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /master_id, childid and subjectid blank/,
			birth_datum.odms_exceptions.first.to_s
	end

	test "bogus_birth_datum factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = FactoryGirl.create(:bogus_birth_datum)
		}
	end

	test "bogus_birth_datum factory should have dob" do
		birth_datum = FactoryGirl.create(:bogus_birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "bogus_birth_datum factory should have sex" do
		birth_datum = FactoryGirl.create(:bogus_birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "bogus_birth_datum factory should have case control flag" do
		birth_datum = FactoryGirl.create(:bogus_birth_datum)
		assert_equal  'bogus', birth_datum.case_control_flag
	end

	test "bogus_birth_datum factory should not have match confidence" do
		birth_datum = FactoryGirl.create(:bogus_birth_datum)
		assert_nil birth_datum.match_confidence
	end









	test "bogus_birth_datum factory should create odms exception if has matching case" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:bogus_birth_datum,:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Unknown case_control_flag :bogus:/,
			birth_datum.odms_exceptions.first.to_s
	end






	test "should link case birth datum to study subject via icf_master_id" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = create_matching_case_birth_datum(study_subject)
		assert_not_nil birth_datum.master_id
		assert_nil birth_datum.childid
		assert_nil birth_datum.subjectid
		assert_equal birth_datum.study_subject, study_subject
	end

	test "should link case birth datum to study subject via childid if icf_master_id is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = create_matching_case_birth_datum(study_subject,
			:master_id => nil, :childid => study_subject.childid)
		assert_nil birth_datum.master_id
		assert_not_nil birth_datum.childid
		assert_nil birth_datum.subjectid
		assert_equal birth_datum.study_subject, study_subject
	end

	test "should link case birth datum to study subject via subjectid if childid and icf_master_id are blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = create_matching_case_birth_datum(study_subject,
			:master_id => nil, :subjectid => study_subject.subjectid)
		assert_nil birth_datum.master_id
		assert_nil birth_datum.childid
		assert_not_nil birth_datum.subjectid
		assert_equal birth_datum.study_subject, study_subject
	end






	test "case_birth_datum factory with matching case should create operational event" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference("study_subject.operational_events.where(" <<
			":operational_event_type_id => #{OperationalEventType['birthDataReceived'].id}" <<
			" ).count",1) {
			create_matching_case_birth_datum(study_subject)
		}
	end

	test "control_birth_datum factory with matching case should create birth datum" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
	end

	test "control_birth_datum factory with matching case should create candidate control" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:master_id => study_subject.icf_master_id )
		assert_not_nil birth_datum.candidate_control
		assert !birth_datum.candidate_control.new_record?
	end

	test "control_birth_datum factory with matching case should not create odms exception" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',0) {
			birth_datum = FactoryGirl.create(:control_birth_datum,
				:master_id => study_subject.icf_master_id )
		}
	end

	test "case birth datum factory should create birth datum if master_id is blank" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_nil birth_datum.master_id
		assert !birth_datum.new_record?
	end

	test "case birth datum factory should create odms exception if master_id is blank" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /master_id, childid and subjectid blank/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "case birth datum should create birth datum if master_id is not blank" <<
			" but not used by a subject" do
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => 'IAMUNUSED')
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, 'IAMUNUSED'
	end

	test "case birth datum should create odms exception if master_id is not blank" <<
			" but not used by a subject" do
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => 'IAMUNUSED')
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /No subject found with master_id :\w+:/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "case birth datum should create birth datum if master_id is not blank and" <<
			" used by a case and match_confidence is definite" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = create_matching_case_birth_datum(study_subject)
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
		assert_equal birth_datum.match_confidence, 'definite'
	end

	test "case birth datum should create operational event if master_id is not blank and" <<
			" used by a case and match_confidence is definite" do
		#	same as above
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference("study_subject.operational_events.where(" <<
			":operational_event_type_id => #{OperationalEventType['birthDataReceived'].id}" <<
			" ).count",1) {
			birth_datum = create_matching_case_birth_datum(study_subject)
		}
	end

	test "case birth datum should not create odms exception if master_id is not blank and" <<
			" used by a case and match_confidence is definite" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',0) {
			birth_datum = create_matching_case_birth_datum(study_subject)
		}
	end

	test "case birth datum should create birth datum if master_id is not blank" <<
			" and used by a case and match_confidence is NOT definite" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,
			:match_confidence => 'somethingelse',
			:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
		assert_equal birth_datum.match_confidence, 'somethingelse'
	end

	test "case birth datum should create odms exception if master_id is not blank" <<
			" and used by a case and match_confidence is NOT definite" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,
			:match_confidence => 'somethingelse',
			:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Match confidence not 'definite':somethingelse:/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "case birth datum should not create operational event if master_id is not blank" <<
			" and used by a case and match_confidence is NOT definite" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OperationalEvent.count',0) {
			birth_datum = FactoryGirl.create(:case_birth_datum,
				:match_confidence => 'somethingelse',
				:master_id => study_subject.icf_master_id )
		}
	end

	test "case birth datum should create birth datum if master_id is not blank" <<
			" and used by a control" do
		study_subject = create_control_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "case birth datum should create odms exception if master_id is not blank" <<
			" and used by a control" do
		study_subject = create_control_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Subject found with master_id :\w+: is not a case subject/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "case birth datum should create birth datum if master_id is not blank" <<
			" and used by a mother" do
		study_subject = create_mother_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "case birth datum should create odms exception if master_id is not blank" <<
			" and used by a mother" do
		study_subject = create_mother_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Subject found with master_id :\w+: is not a case subject/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should create birth datum if master_id is blank" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert !birth_datum.new_record?
		assert_nil birth_datum.master_id
	end

	test "control birth datum should create odms exception if master_id is blank" do
		birth_datum = FactoryGirl.create(:control_birth_datum)
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /master_id, childid and subjectid blank/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should create birth datum if master_id is not blank" <<
			" but not used by a subject" do
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => 'IAMUNUSED')
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, 'IAMUNUSED'
	end

	test "control birth datum should create odms exception if master_id is not blank" <<
			" but not used by a subject" do
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => 'IAMUNUSED')
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /No subject found with master_id :\w+:/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should create birth datum if master_id is not blank" <<
			" and used by a case" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "control birth datum should create candidate control if master_id is not blank" <<
			" and used by a case" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert_not_nil birth_datum.candidate_control
		assert !birth_datum.candidate_control.new_record?
		assert !birth_datum.candidate_control.reject_candidate
		assert_equal birth_datum.candidate_control.related_patid, 
			study_subject.patid
	end

	test "control birth datum should not create odms exception if master_id is not blank" <<
			" and used by a case" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',0) {
			birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		}
	end

	test "control birth datum should create birth datum if" <<
			" create candidate control fails" do
		CandidateControl.any_instance.stubs(:create_or_update).returns(false)
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "control birth datum should create odms exception if" <<
			" create candidate control fails" do
		CandidateControl.any_instance.stubs(:create_or_update).returns(false)
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'candidate control creation',
			birth_datum.odms_exceptions.first.name
		assert_match /Error creating candidate_control for subject/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should not create candidate control if" <<
			" create candidate control fails" do
		CandidateControl.any_instance.stubs(:create_or_update).returns(false)
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('CandidateControl.count',0) {
			birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
			assert birth_datum.candidate_control.new_record?
		}
	end

	test "control birth datum should create birth datum if master_id is not blank" <<
			" and used by a control" do
		study_subject = create_control_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "control birth datum should create odms exception if master_id is not blank" <<
			" and used by a control" do
		study_subject = create_control_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Subject found with master_id :\w+: is not a case subject/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should create birth datum if master_id is not blank" <<
			" and used by a mother" do
		study_subject = create_mother_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "control birth datum should create odms exception if master_id is not blank" <<
			" and used by a mother" do
		study_subject = create_mother_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Subject found with master_id :\w+: is not a case subject/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should create birth datum if sex is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:sex => nil,
			:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "control birth datum should create odms exception if sex is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:sex => nil,
			:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Candidate control was pre-rejected because Birth datum sex is blank/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should pre-reject candidate if sex is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:sex => nil,
			:master_id => study_subject.icf_master_id )
		assert !birth_datum.candidate_control.new_record?
		assert_not_nil birth_datum.candidate_control
		assert birth_datum.candidate_control.reject_candidate
	end

	test "control birth datum should create birth datum if dob is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:dob => nil,
			:master_id => study_subject.icf_master_id )
		assert !birth_datum.new_record?
		assert_equal birth_datum.master_id, study_subject.icf_master_id
	end

	test "control birth datum should create odms exception if dob is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:dob => nil,
			:master_id => study_subject.icf_master_id )
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /Candidate control was pre-rejected because Birth datum dob is blank/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "control birth datum should pre-reject candidate if dob is blank" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:control_birth_datum,
			:dob => nil,
			:master_id => study_subject.icf_master_id )
		assert !birth_datum.candidate_control.new_record?
		assert_not_nil birth_datum.candidate_control
		assert birth_datum.candidate_control.reject_candidate
	end

	test "case birth datum should assign study_subject_id if exists" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = FactoryGirl.create(:case_birth_datum,:master_id => study_subject.icf_master_id)
		assert_not_nil birth_datum.study_subject_id
		assert_equal   birth_datum.study_subject_id, study_subject.id
	end

	test "case birth datum should NOT assign study_subject_id if doesn't exist" do
		birth_datum = FactoryGirl.create(:case_birth_datum)
		assert_nil birth_datum.study_subject_id
	end

	test "control birth datum should assign related patid to candidate control" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = FactoryGirl.create(:control_birth_datum,
				:master_id => study_subject.icf_master_id)
			assert_not_nil birth_datum.candidate_control
			assert_not_nil birth_datum.candidate_control.related_patid
		} }
	end

	test "should return join of birth_datum's name" do
		birth_datum = BirthDatum.new(
			:first_name  => "John",
			:middle_name => "Michael",
			:last_name   => "Smith" )
		assert_equal 'John Michael Smith', birth_datum.full_name 
	end

	test "should return join of birth_datum's name with blank middle name" do
		birth_datum = BirthDatum.new(
			:first_name  => "John",
			:middle_name => "",
			:last_name   => "Smith" )
		assert_equal 'John Smith', birth_datum.full_name 
	end

	test "should return join of birth_datum's mother's name" do
		birth_datum = BirthDatum.new(
			:mother_first_name  => "Jane",
			:mother_middle_name => "Anne",
			:mother_maiden_name => "Smith" )
		assert_equal 'Jane Anne Smith', birth_datum.mother_full_name 
	end

	test "should return join of birth_datum's mother's name with blank mother's middle name" do
		birth_datum = BirthDatum.new(
			:mother_first_name  => "Jane",
			:mother_middle_name => "",
			:mother_maiden_name => "Smith" )
		assert_equal 'Jane Smith', birth_datum.mother_full_name 
	end

	test "case birth datum update_study_subject_attributes should update" <<
			" subject attributes middle name" do
		birth_datum = FactoryGirl.create(:case_birth_datum,
			:middle_name => 'mynewmiddlename',
			:master_id    => '12345678A' )
		study_subject = FactoryGirl.create(:case_study_subject,
			:icf_master_id => '12345678A' )
		assert_nil study_subject.middle_name
		birth_datum.update_study_subject_attributes
		study_subject.reload
		assert_equal 'Mynewmiddlename', study_subject.middle_name
	end

	test "case birth datum update_study_subject_attributes should do nothing" <<
			" without matching subject" do
		birth_datum = FactoryGirl.create(:case_birth_datum,
			:middle_name => 'mynewmiddlename',
			:master_id    => '12345678A' )
		birth_datum.update_study_subject_attributes
	end

	test "case birth datum update_study_subject_attributes should do nothing" <<
			" without master_id" do
		birth_datum = FactoryGirl.create(:case_birth_datum,
			:middle_name => 'mynewmiddlename' )
		birth_datum.update_study_subject_attributes
	end

	test "case birth datum should not create odms exception on success" do
		assert_difference('OdmsException.count', 0){
			study_subject, birth_datum = create_case_study_subject_and_birth_datum
		}
	end

	test "case birth datum should create operational event on success" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum
		oes = study_subject.operational_events.where(
			:project_id                => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['birthDataReceived'].id 
			)
		assert_equal 1, oes.length
#		assert_match /Error updating case study subject. Save failed!/,
#			oes.first.description
	end


	#	NOTE dob and sex aren't just strings so require special handling
	test "case birth datum should create operational event if dob differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:dob => ( Date.current - 10.days ) }, {:dob => ( Date.current - 5.days ) })
		oes = study_subject.operational_events.where(
			:project_id                => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
			)
		assert_equal 1, oes.length
		assert_match /Field: dob,/,
			oes.first.description
	end

	test "case birth datum should create operational event if sex differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:sex => 'M'}, { :sex => 'F' })
		oes = study_subject.operational_events.where(
			:project_id                => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
			)
		assert_equal 1, oes.length
		assert_match /Field: sex,/,
			oes.first.description
	end

	test "case birth datum should create operational event if sex and case differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:sex => 'M'}, { :sex => ' f ' })
		oes = study_subject.operational_events.where(
			:project_id                => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
			)
		assert_equal 1, oes.length
		assert_match /Field: sex,/,
			oes.first.description
	end

	test "case birth datum should NOT create operational event if sex case differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:sex => 'M'}, { :sex => ' m ' })
		oes = study_subject.operational_events.where(
			:project_id                => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
			)
		assert_equal 0, oes.length
	end

	test "case birth datum should create odms exception if dob differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:dob => ( Date.current - 10.days ) }, {:dob => ( Date.current - 5.days ) })
		oes = birth_datum.odms_exceptions
		assert_equal 1, oes.length
		assert_match /Error updating case study subject/,
			oes.first.description
	end

	test "case birth datum should create odms exception if sex differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:sex => 'M'}, { :sex => 'F' })
		oes = birth_datum.odms_exceptions
		assert_equal 1, oes.length
		assert_match /Error updating case study subject/,
			oes.first.description
	end

	test "case birth datum should create odms exception if sex and case differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:sex => 'M'}, { :sex => ' f ' })
		oes = birth_datum.odms_exceptions
		assert_equal 1, oes.length
		assert_match /Error updating case study subject/,
			oes.first.description
	end

	test "case birth datum should NOT create odms exception if sex case differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:sex => 'M'}, { :sex => ' m ' })
		oes = birth_datum.odms_exceptions
		assert_equal 0, oes.length
	end

	%w( first_name last_name middle_name
			father_first_name father_middle_name father_last_name 
			mother_first_name mother_middle_name mother_maiden_name
			).each do |field|

		test "case birth datum should create operational event if #{field} differs" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => 'studysubjectvalue'}, {field => 'birthdatumvalue'})
			oes = study_subject.operational_events.where(
				:project_id                => Project['ccls'].id).where(
				:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
				)
			assert_equal 1, oes.length
			assert_match /Field: #{field}, ODMS Value: studysubjectvalue, Birth Record Value: Birthdatumvalue/,
				oes.first.description
#puts oes.first.description
#	Birth record data conflicted with existing ODMS data.  Field: mother_middle_name, ODMS Value: studysubjectvalue, Birth Record Value: birthdatumvalue.  ODMS record modified with birth record data.
		end

		test "case birth datum should create odms exception if #{field} differs" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => 'studysubjectvalue'}, {field => 'birthdatumvalue'})
			oes = birth_datum.odms_exceptions
			assert_equal 1, oes.length
			assert_match /Error updating case study subject/,
				oes.first.description
		end

		test "case birth datum should NOT create operational event if #{field} case differs" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => 'Study Subject Value'}, {field => ' STUDY SUBJECT VALUE '})
			oes = study_subject.operational_events.where(
				:project_id                => Project['ccls'].id).where(
				:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
				)
			assert_equal 0, oes.length
		end

		test "case birth datum should NOT create odms exception if #{field} case differs" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => 'Study Subject Value'}, {field => ' STUDY SUBJECT VALUE '})
			oes = birth_datum.odms_exceptions
			assert_equal 0, oes.length
		end

	end

	%w( middle_name
			father_first_name father_middle_name father_last_name 
			mother_first_name mother_middle_name mother_maiden_name
			).each do |field|

		test "case birth datum should import value if #{field} blank" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => ''}, {field => 'Iamnotblank'})
			study_subject.reload
			assert_equal study_subject.send(field), 'Iamnotblank'
		end

		test "case birth datum should namerize import value if #{field} blank" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => ''}, {field => 'iamnot blank'})
			study_subject.reload
			assert_equal study_subject.send(field), 'Iamnot Blank'
		end

		#	this is kinda already tested as is just success
		test "case birth datum should create operational event if #{field} blank" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => ''}, {field => 'iamnotblank'})
			oes = study_subject.operational_events.where(
				:project_id                => Project['ccls'].id).where(
				:operational_event_type_id => OperationalEventType['birthDataReceived'].id 
				)
			assert_equal 1, oes.length
			assert_match /Birth Data for subject received from USC/,
				oes.first.description
			oes = study_subject.operational_events.where(
				:project_id                => Project['ccls'].id).where(
				:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
				)
			assert_equal 1, oes.length
			assert_match /Birth record data conflicted with existing ODMS data.  Field: #{field}, ODMS Value was blank, Birth Record Value: Iamnotblank.  ODMS record modified with birth record data./, oes.first.description
		end

		test "case birth datum should not create odms exception if #{field} blank" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => ''}, {field => 'iamnotblank'})
			oes = birth_datum.odms_exceptions
			assert_equal 0, oes.length
		end

	end

	test "case birth datum should create odms exception of subject save fails" do
		study_subject = create_case_study_subject_with_icf_master_id
		StudySubject.any_instance.stubs(:create_or_update).returns(false)
		birth_datum = create_matching_case_birth_datum(study_subject,
			:middle_name => 'mynewmiddlename')
		oes = birth_datum.odms_exceptions
		assert_match /Error updating case study subject. Save failed!/,
			oes.first.description
	end



	test "case birth datum should create addressing" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('Addressing.count',1) {
			create_matching_case_birth_datum_with_address(study_subject)
		}
		assert_equal AddressType['residence'], study_subject.addresses.last.address_type
	end

	test "case birth datum should create addressing even with PO Box" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('Addressing.count',1) {
			create_matching_case_birth_datum_with_address(study_subject,{
				:mother_residence_line_1 => 'PO Box 1995' })
		}
		assert_equal AddressType['mailing'], study_subject.addresses.last.address_type
	end

	test "case birth datum should create address" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('Address.count',1) {
			create_matching_case_birth_datum_with_address(study_subject)
		}
		assert_equal AddressType['residence'], study_subject.addresses.last.address_type
	end

	test "case birth datum should create address even with PO Box" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('Address.count',1) {
			create_matching_case_birth_datum_with_address(study_subject,{
				:mother_residence_line_1 => 'PO Box 1995' })
		}
		assert_equal AddressType['mailing'], study_subject.addresses.last.address_type
	end

	test "case birth datum should create event if addressing invalid" do
		study_subject = create_case_study_subject_with_icf_master_id
		Addressing.any_instance.stubs(:valid?).returns(false)
		assert_difference("study_subject.operational_events.where(" <<
			":operational_event_type_id => #{OperationalEventType['bc_received'].id}" <<
			").count",1) {
		assert_difference('Addressing.count',0) {
			create_matching_case_birth_datum_with_address(study_subject)
		} }
	end

	#	As address is created via nested attributes, its validity isn't checked
	#	However, create_or_update returning false will trigger failure.
	test "case birth datum should create event if address save fails" do
		study_subject = create_case_study_subject_with_icf_master_id
		Address.any_instance.stubs(:create_or_update).returns(false)
		assert_difference("study_subject.operational_events.where(" <<
			":operational_event_type_id => #{OperationalEventType['bc_received'].id}" <<
			").count",1) {
		assert_difference('Address.count',0) {
			create_matching_case_birth_datum_with_address(study_subject)
		} }
	end

	test "should mark associated case bc_requests as complete" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('BcRequest.active.count',1){
			study_subject.bc_requests.create(:status => 'active')
		}
		assert_difference('BcRequest.count',0){
		assert_difference('BcRequest.active.count',-1){
		assert_difference('BcRequest.complete.count',1){
			FactoryGirl.create(:case_birth_datum,:master_id => study_subject.icf_master_id )
		} } }
		bcr = study_subject.bc_requests.first
		assert_not_nil bcr.is_found
		assert_not_nil bcr.returned_on
		assert_equal Date.current, bcr.returned_on
		assert_not_nil bcr.notes
		assert_equal "USC's match confidence = definite.", bcr.notes
	end

protected

	def create_case_study_subject_and_birth_datum(
			subject_options={},birth_datum_options={})
		study_subject = create_case_study_subject_with_icf_master_id(subject_options)
		birth_datum = create_matching_case_birth_datum(study_subject,birth_datum_options)
		return study_subject, birth_datum
	end

	def create_matching_case_birth_datum_with_address(study_subject,options={})
		create_matching_case_birth_datum(study_subject,{
			:mother_residence_line_1 => '1995 UNIVERSITY AVE #460',
			:mother_residence_city   => 'BERKELEY',
			:mother_residence_county => 'ALAMEDA',
			:mother_residence_state  => 'CA',
			:mother_residence_zip    => '94704'
		}.merge(options))
	end

	def create_matching_case_birth_datum(study_subject,options={})
		birth_datum = FactoryGirl.create(:case_birth_datum,{
			:sex => study_subject.sex,
			:dob => study_subject.dob,
			:match_confidence => 'definite',
			:master_id => study_subject.icf_master_id }.merge(options) )
	end

	def create_case_study_subject_with_icf_master_id(options={})
		study_subject = FactoryGirl.create(:case_study_subject,{
			:icf_master_id => '12345678A' }.merge(options))
		check_icf_master_id(study_subject)
	end

	def create_control_study_subject_with_icf_master_id
		study_subject = FactoryGirl.create(:control_study_subject,
			:icf_master_id => '12345678A')
		check_icf_master_id(study_subject)
	end

	def create_mother_study_subject_with_icf_master_id
		study_subject = FactoryGirl.create(:mother_study_subject,
			:icf_master_id => '12345678A')
		check_icf_master_id(study_subject)
	end

	def check_icf_master_id(study_subject)
#		assert_nil study_subject.icf_master_id
#		imi = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345678A')
#		study_subject.assign_icf_master_id
		assert_not_nil study_subject.icf_master_id
		assert_equal '12345678A', study_subject.icf_master_id
		study_subject
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_birth_datum

end
