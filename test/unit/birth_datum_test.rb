require 'test_helper'

class BirthDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )
	assert_should_belong_to( :birth_datum_update )

#	needs special test as is created in an after_create
#	assert_should_have_one( :candidate_control )

	test "birth_datum factory should create birth datum" do
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:birth_datum)
		}
	end

	test "birth_datum factory should create odms exception" do
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:birth_datum)
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.to_s
		}
	end

	test "birth_datum factory should NOT create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = Factory(:birth_datum)
		}
	end

	test "birth_datum factory should have dob" do
		birth_datum = Factory(:birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "birth_datum factory should have sex" do
		birth_datum = Factory(:birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "birth_datum factory should not have first name" do
		birth_datum = Factory(:birth_datum)
		assert_nil birth_datum.first_name
	end

	test "birth_datum factory should not have last name" do
		birth_datum = Factory(:birth_datum)
		assert_nil birth_datum.last_name
	end

	test "birth_datum factory should not have case control flag" do
		birth_datum = Factory(:birth_datum)
		assert_nil birth_datum.case_control_flag
	end

	test "birth_datum factory should not have match confidence" do
		birth_datum = Factory(:birth_datum)
		assert_nil birth_datum.match_confidence
	end

	test "case_birth_datum factory should create birth datum" do
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:case_birth_datum)
		}
	end

	test "case_birth_datum factory should create odms exception" do
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:case_birth_datum)
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.to_s
		}
	end

	test "case_birth_datum factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = Factory(:case_birth_datum)
		}
	end

	test "case_birth_datum factory should have dob" do
		birth_datum = Factory(:case_birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "case_birth_datum factory should have sex" do
		birth_datum = Factory(:case_birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "case_birth_datum factory should have case control flag" do
		birth_datum = Factory(:case_birth_datum)
		assert_equal 'case', birth_datum.case_control_flag
	end

	test "case_birth_datum factory should have match confidence" do
		birth_datum = Factory(:case_birth_datum)
		assert_equal 'definite', birth_datum.match_confidence
	end

	test "control_birth_datum factory should create birth datum" do
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:control_birth_datum)
		}
	end

	test "control_birth_datum factory should create odms exception" do
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:control_birth_datum)
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.to_s
		}
	end

	test "control_birth_datum factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = Factory(:control_birth_datum)
		}
	end

	test "control_birth_datum factory should have dob" do
		birth_datum = Factory(:control_birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "control_birth_datum factory should have sex" do
		birth_datum = Factory(:control_birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "control_birth_datum factory should have case control flag" do
		birth_datum = Factory(:control_birth_datum)
		assert_equal  'control', birth_datum.case_control_flag
	end

	test "control_birth_datum factory should not have match confidence" do
		birth_datum = Factory(:control_birth_datum)
		assert_nil birth_datum.match_confidence
	end

	test "bogus_birth_datum factory should create birth datum" do
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:bogus_birth_datum)
		}
	end

	test "bogus_birth_datum factory should create odms exception" do
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:bogus_birth_datum)
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.first.to_s
		}
	end

	test "bogus_birth_datum factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {
			birth_datum = Factory(:bogus_birth_datum)
		}
	end

	test "bogus_birth_datum factory should have dob" do
		birth_datum = Factory(:bogus_birth_datum)
		assert_not_nil birth_datum.dob
	end

	test "bogus_birth_datum factory should have sex" do
		birth_datum = Factory(:bogus_birth_datum)
		assert_not_nil birth_datum.sex
	end

	test "bogus_birth_datum factory should have case control flag" do
		birth_datum = Factory(:bogus_birth_datum)
		assert_equal  'bogus', birth_datum.case_control_flag
	end

	test "bogus_birth_datum factory should not have match confidence" do
		birth_datum = Factory(:bogus_birth_datum)
		assert_nil birth_datum.match_confidence
	end

	test "case_birth_datum factory with matching case should create operational event" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OperationalEvent.count',1) {
#		assert_difference('OdmsException.count',0) {
#		assert_difference('CandidateControl.count',0) {
#		assert_difference('BirthDatum.count',1) {
			create_matching_case_birth_datum(study_subject)
#			#	No differences, so no updates, just operational event
#			birth_datum = Factory(:case_birth_datum,
#				:sex => study_subject.sex,
#				:dob => study_subject.dob,
#				:masterid => study_subject.icf_master_id )
		} #} } }
	end

	test "control_birth_datum factory with matching case should create candidate control" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('OdmsException.count',0) {
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:control_birth_datum,
				:masterid => study_subject.icf_master_id )
		} } }
	end

	test "case birth datum factory should create odms exception if masterid is blank" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:case_birth_datum)
			assert_nil birth_datum.masterid
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "case birth datum should create odms exception if masterid is not blank" <<
			" but not used by a subject" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:case_birth_datum,:masterid => 'IAMUNUSED')
			assert_equal birth_datum.masterid, 'IAMUNUSED'
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /No subject found with masterid :\w+:/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "case birth datum should update case subject if masterid is not blank and" <<
			" used by a case and match_confidence is definite" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference('BirthDatum.count',1) {
		assert_difference('OperationalEvent.count',1) {
		assert_difference('OdmsException.count',0) {
			#	No differences, so no updates, just operational event
#			birth_datum = Factory(:case_birth_datum,
#				:sex => study_subject.sex,
#				:dob => study_subject.dob,
#				:match_confidence => 'definite', 	#	default
#				:masterid => study_subject.icf_master_id )
			birth_datum = create_matching_case_birth_datum(study_subject)
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_equal birth_datum.match_confidence, 'definite'
		} } }
	end

	test "case birth datum should NOT update case subject if masterid is not blank" <<
			" and used by a case and match_confidence is NOT definite" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_case_study_subject_with_icf_master_id
			birth_datum = Factory(:case_birth_datum,
				:match_confidence => 'somethingelse',
				:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_equal birth_datum.match_confidence, 'somethingelse'
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Match confidence not 'definite':somethingelse:/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "case birth datum should create odms exception if masterid is not blank" <<
			" and used by a control" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_control_study_subject_with_icf_master_id
			birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "case birth datum should create odms exception if masterid is not blank" <<
			" and used by a mother" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_mother_study_subject_with_icf_master_id
			birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "control birth datum should create odms exception if masterid is blank" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:control_birth_datum)
			assert_nil birth_datum.masterid
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /masterid blank/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "control birth datum should create odms exception if masterid is not blank" <<
			" but not used by a subject" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			birth_datum = Factory(:control_birth_datum,:masterid => 'IAMUNUSED')
			assert_equal birth_datum.masterid, 'IAMUNUSED'
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /No subject found with masterid :\w+:/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "control birth datum should create candidate control if masterid is not blank" <<
			" and used by a case" do
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

	test "control birth datum should create odms exception if" <<
			" create candidate control fails" do
		CandidateControl.any_instance.stubs(:create_or_update).returns(false)
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',0) {
			study_subject = create_case_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
#			assert_not_nil birth_datum.candidate_control
#			assert !birth_datum.candidate_control.reject_candidate
#			assert_equal birth_datum.candidate_control.related_patid, 
#				study_subject.patid
			assert_equal 'candidate control creation',
				birth_datum.odms_exceptions.first.name
			assert_match /Error creating candidate_control for subject/,
				birth_datum.odms_exceptions.last.to_s
		} } }
	end

	test "control birth datum should create odms exception if masterid is not blank" <<
			" and used by a control" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_control_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "control birth datum should create odms exception if masterid is not blank" <<
			" and used by a mother" do
		assert_difference('BirthDatum.count',1) {
		assert_difference('OdmsException.count',1) {
			study_subject = create_mother_study_subject_with_icf_master_id
			birth_datum = Factory(:control_birth_datum,:masterid => study_subject.icf_master_id )
			assert_equal birth_datum.masterid, study_subject.icf_master_id
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Subject found with masterid :\w+: is not a case subject/,
				birth_datum.odms_exceptions.last.to_s
		} }
	end

	test "control birth datum should pre-reject candidate if sex is blank" do
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
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Candidate control was pre-rejected because Birth datum sex is blank/,
				birth_datum.odms_exceptions.last.to_s
		} } }
	end

	test "control birth datum should pre-reject candidate if dob is blank" do
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
			assert_equal 'birth data append',
				birth_datum.odms_exceptions.first.name
			assert_match /Candidate control was pre-rejected because Birth datum dob is blank/,
				birth_datum.odms_exceptions.last.to_s
		} } }
	end

	test "case birth datum should assign study_subject_id if exists" do
		study_subject = create_case_study_subject_with_icf_master_id
		birth_datum = Factory(:case_birth_datum,:masterid => study_subject.icf_master_id)
		assert_not_nil birth_datum.study_subject_id
		assert_equal   birth_datum.study_subject_id, study_subject.id
	end

	test "case birth datum should NOT assign study_subject_id if doesn't exist" do
		birth_datum = Factory(:case_birth_datum)
		assert_nil birth_datum.study_subject_id
	end

	test "control birth datum should assign related patid to candidate control" do
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



#	TODO also, add explicit tests to update_case_study_subject?



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
			).length
		assert_equal 1, oes.length
#		assert_match /Error updating case study subject. Save failed!/,
#			oes.first.description
	end

	#	NOTE dob and sex aren't just strings so require special handling
	test "case birth datum should create operational event if dob differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:dob => ( Date.today - 10 ) }, {:dob => ( Date.today - 5 ) })
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

	test "case birth datum should create odms exception if dob differs" do
		study_subject, birth_datum = create_case_study_subject_and_birth_datum(
			{:dob => ( Date.today - 10 ) }, {:dob => ( Date.today - 5 ) })
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
			assert_match /Field: #{field}, ODMS Value: studysubjectvalue, Birth Record Value: birthdatumvalue/,
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

	end

	%w( middle_name
			father_first_name father_middle_name father_last_name 
			mother_first_name mother_middle_name mother_maiden_name
			).each do |field|

		test "case birth datum should import value if #{field} blank" do
			study_subject, birth_datum = create_case_study_subject_and_birth_datum(
				{field => ''}, {field => 'iamnotblank'})
			study_subject.reload
			assert_equal study_subject.send(field), 'iamnotblank'
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
#			assert_match /Error updating case study subject. Save failed!/,
#				oes.first.description
			oes = study_subject.operational_events.where(
				:project_id                => Project['ccls'].id).where(
				:operational_event_type_id => OperationalEventType['birthDataConflict'].id 
				)
			assert_equal 0, oes.length
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

protected

	def create_case_study_subject_and_birth_datum(
			subject_options={},birth_datum_options={})
		study_subject = create_case_study_subject_with_icf_master_id(subject_options)
		birth_datum = create_matching_case_birth_datum(study_subject,birth_datum_options)
		return study_subject, birth_datum
	end

	def create_matching_case_birth_datum(study_subject,options={})
		birth_datum = Factory(:case_birth_datum,{
			:sex => study_subject.sex,
			:dob => study_subject.dob,
			:match_confidence => 'definite',
			:masterid => study_subject.icf_master_id }.merge(options) )
	end

	def create_case_study_subject_with_icf_master_id(options={})
		study_subject = Factory(:case_study_subject,{
			:icf_master_id => '12345678A' }.merge(options))
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
