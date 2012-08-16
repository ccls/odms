require 'test_helper'

class ScreeningDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )
	assert_should_belong_to( :screening_datum_update )

	test "screening_datum factory should create odms exception" do
		screening_datum = Factory(:screening_datum)
		assert_equal 1,
			screening_datum.odms_exceptions.length
		assert_equal 'screening data append',
			screening_datum.odms_exceptions.first.name
		assert_match /icf_master_id blank/,
			screening_datum.odms_exceptions.first.to_s
	end

	test "screening_datum factory should create screening datum" do
		screening_datum = Factory(:screening_datum)
		assert !screening_datum.new_record?
	end

	test "screening_datum factory should have dob" do
		screening_datum = Factory(:screening_datum)
		assert_not_nil screening_datum.dob
	end

	test "screening_datum factory should have sex" do
		screening_datum = Factory(:screening_datum)
		assert_not_nil screening_datum.sex
	end

	test "screening_datum factory should not have first name" do
		screening_datum = Factory(:screening_datum)
		assert_nil screening_datum.first_name
	end

	test "screening_datum factory should not have last name" do
		screening_datum = Factory(:screening_datum)
		assert_nil screening_datum.last_name
	end


#	Section 2: Modify the value in study_subjects.  Create an operational event:  ICF Screening data change:  The value in fieldname has changed from [original value] to [new value]
#	new_mother_first_name
#	new_mother_last_name
#	new_mother_maiden_name
#	new_father_first_name
#	new_father_last_name
#	new_first_name
#	new_middle_name
#	new_last_name
#	new_dob
#	new_sex
#	
#Section 3:  Write code to do the following with this date:	
#	
#date	add an operational event:  oe_type_id=26 (screener), occurred_at=date (that is, the value in the date column.  We won't have time data), description: "ICF screening complete. " 
#mother_hispanicity	identify the correct mother_hispanicity_id from the value provided.  If no value matches, add operational event:  oe_type_id=30 (dataconflict), occurred_at=now, description:  "ICF screening data conflict:  mother's hispanicity does not match CCLS designations.    Value = "[value from file]"
#mother_race	identify the correct mother_race_id from the value provided.  If no value matches, add operational event:  oe_type_id=30 (dataconflict), occurred_at=now, description:  "ICF screening data conflict:  mother's race does not match CCLS designations.    Value = [value from file]
#father_hispanicity	identify the correct father_hispanicity_id from the value provided.  If no value matches, add operational event:  oe_type_id=30 (dataconflict), occurred_at=now, description:  "ICF screening data conflict:  father's hispanicity does not match CCLS designations.    Value = [value from file]
#father_race	identify the correct father_race_id from the value provided.  If no value matches, add operational event:  oe_type_id=30 (dataconflict), occurred_at=now, description:  "ICF screening data conflict:  father's race does not match CCLS designations.    Value = [value from file]
#


	#	create_object is called from within the common class tests
	alias_method :create_object, :create_screening_datum

end
__END__

other potential test examples from BirthDatumUpdate

	test "case_birth_datum factory with matching case should create operational event" do
		study_subject = create_case_study_subject_with_icf_master_id
		assert_difference("study_subject.operational_events.where(" <<
			":operational_event_type_id => #{OperationalEventType['birthDataReceived'].id}" <<
			" ).count",1) {
			create_matching_case_birth_datum(study_subject)
		}
	end

	test "case birth datum should create odms exception if master_id is not blank" <<
			" but not used by a subject" do
		birth_datum = Factory(:case_birth_datum,:master_id => 'IAMUNUSED')
		assert_equal 1,
			birth_datum.odms_exceptions.length
		assert_equal 'birth data append',
			birth_datum.odms_exceptions.first.name
		assert_match /No subject found with master_id :\w+:/,
			birth_datum.odms_exceptions.last.to_s
	end

	test "case birth datum update_study_subject_attributes should do nothing" <<
			" without master_id" do
		birth_datum = Factory(:case_birth_datum,
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
		birth_datum = Factory(:case_birth_datum,{
			:sex => study_subject.sex,
			:dob => study_subject.dob,
			:match_confidence => 'definite',
			:master_id => study_subject.icf_master_id }.merge(options) )
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
