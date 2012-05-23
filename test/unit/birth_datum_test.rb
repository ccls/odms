require 'test_helper'

class BirthDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )
	assert_should_belong_to( :birth_datum_update )

#	needs special test as is created in an after_create
#	assert_should_have_one( :candidate_control )

	test "explicit Factory birth_datum test" do
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:birth_datum)
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_nil     birth_datum.case_control_flag
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.notes
		} } }
	end

	test "explicit Factory case_birth_datum test" do
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:case_birth_datum)
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'case', birth_datum.case_control_flag
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.notes
		} } }
	end

	test "explicit Factory control_birth_datum test" do
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:control_birth_datum)
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'control', birth_datum.case_control_flag
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.notes
		} } }
	end

	test "explicit Factory bogus_birth_datum test" do
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:bogus_birth_datum)
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'bogus', birth_datum.case_control_flag
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.notes
		} } }
	end

	test "explicit Factory case_birth_datum test with matching case" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',0) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:case_birth_datum,
				:masterid => study_subject.icf_master_id )

pending	#	TODO should update case attributes, but which ones?

#			assert_equal 'First', birth_datum.first_name
#			assert_equal 'Last',  birth_datum.last_name
#			assert_not_nil birth_datum.dob
#			assert_not_nil birth_datum.sex
			assert_equal  'case', birth_datum.case_control_flag
			assert_not_nil birth_datum.masterid
			assert_equal   birth_datum.masterid, study_subject.icf_master_id
		} } }
	end

	test "explicit Factory control_birth_datum test with matching case" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',0) {
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:control_birth_datum,
				:masterid => study_subject.icf_master_id )
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'control', birth_datum.case_control_flag
			assert_not_nil birth_datum.masterid
			assert_equal   birth_datum.masterid, study_subject.icf_master_id
		} } }
	end

	test "explicit Factory bogus_birth_datum test with matching case" do
		#	shouldn't really do anything different
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:bogus_birth_datum,
				:masterid => study_subject.icf_master_id )
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'bogus', birth_datum.case_control_flag
			assert_match /Unknown case_control_flag/,
				birth_datum.odms_exceptions.first.notes
		} } }
	end

	test "should create odms exception if masterid is blank" <<
			" for case birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:case_birth_datum)
			assert_nil birth_datum.masterid
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should create odms exception if masterid is not blank, but not used by a subject" <<
			" for case birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:case_birth_datum,:masterid => 'IAMUNUSED')
			assert_equal birth_datum.masterid, 'IAMUNUSED'
			assert_match /No subject found with masterid :\w+:/,
				birth_datum.odms_exceptions.last.notes
		} }
	end



#	TODO and don't forget about match_confidence (only refers to cases if I read it right)

	test "should update case subject if masterid is not blank and used by a case" <<
			" for case birth datum" do
pending	#	TODO
#
#	should possibly update some fields for the subject
#	which fields has yet to be determined
#
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',0) {
			study_subject = create_case_study_subject_with_icf_master_id
			birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
		} }
	end




	test "should create odms exception if masterid is not blank and used by a control" <<
			" for case birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_control_study_subject_with_icf_master_id
			birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should create odms exception if masterid is not blank and used by a mother" <<
			" for case birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_mother_study_subject_with_icf_master_id
			birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should create odms exception if masterid is blank" <<
			" for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:control_birth_datum)
			assert_nil birth_datum.masterid
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should create odms exception if masterid is not blank, but not used by a subject" <<
			" for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:control_birth_datum,:masterid => 'IAMUNUSED')
			assert_equal birth_datum.masterid, 'IAMUNUSED'
			assert_match /No subject found with masterid :\w+:/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should create candidate control if masterid is not blank and used by a case" <<
			" for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',0) {
		assert_difference('CandidateControl.count',1) {
			study_subject = create_case_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_not_nil birth_datum.candidate_control
			assert !birth_datum.candidate_control.reject_candidate
			assert_equal birth_datum.candidate_control.related_patid, 
				study_subject.patid
		} } }
	end

	test "should create odms exception if masterid is not blank and used by a control" <<
			" for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_control_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should create odms exception if masterid is not blank and used by a mother" <<
			" for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_mother_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.notes
		} }
	end

	test "should pre-reject candidate if sex is blank for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',1) {
			study_subject = create_case_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,
				:sex => nil,
				:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_not_nil birth_datum.candidate_control
			assert birth_datum.candidate_control.reject_candidate
			assert_match /Candidate control was pre-rejected because Birth datum sex is blank/,
				birth_datum.odms_exceptions.last.notes
		} } }
	end

	test "should pre-reject candidate if dob is blank for control birth datum" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',1) {
			study_subject = create_case_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,
				:dob => nil,
				:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_not_nil birth_datum.candidate_control
			assert birth_datum.candidate_control.reject_candidate
			assert_match /Candidate control was pre-rejected because Birth datum dob is blank/,
				birth_datum.odms_exceptions.last.notes
		} } }
	end

	test "should assign study_subject_id on case create if exists" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id)
		assert_not_nil birth_datum.study_subject_id
		assert_equal   birth_datum.study_subject_id, study_subject.id
	end

	test "should NOT assign study_subject_id on case create if doesn't exist" do
		birth_datum = Factory(:case_birth_datum)
		assert_nil birth_datum.study_subject_id
	end

	test "should assign related patid to candidate control on control create" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:control_birth_datum,
				:masterid => study_subject.icf_master_id)
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

protected

	def create_case_study_subject_with_icf_master_id
		study_subject = Factory(:case_study_subject,
			:icf_master_id => '12345678A')
		check_icf_master_id(study_subject)
	end

	def create_control_study_subject_with_icf_master_id
		study_subject = Factory(:control_study_subject,
			:icf_master_id => '12345678A')
		check_icf_master_id(study_subject)
	end

	def create_mother_study_subject_with_icf_master_id
		study_subject = Factory(:mother_study_subject,
			:icf_master_id => '12345678A')
		check_icf_master_id(study_subject)
	end

	def check_icf_master_id(study_subject)
#		assert_nil study_subject.icf_master_id
#		imi = Factory(:icf_master_id,:icf_master_id => '12345678A')
#		study_subject.assign_icf_master_id
		assert_not_nil study_subject.icf_master_id
		assert_equal '12345678A', study_subject.icf_master_id
		study_subject
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_birth_datum

end
