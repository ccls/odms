require 'test_helper'

#	This is just a collection of patient related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectPatientTest < ActiveSupport::TestCase

	%w( admit_date organization 
			organization_id hospital_no
			patient_was_ca_resident_at_diagnosis
			patient_was_previously_treated
			patient_was_under_15_at_dx
		).each do |method_name|

		test "should respond to #{method_name}" do
			study_subject = StudySubject.new
			assert study_subject.respond_to?(method_name)
		end

	end

#	test "set organization for complete case study subject factory test" do
#		#	Factory only does a merge, NOT a deep_merge, so this won' work
#		s = Factory(:complete_case_study_subject,
#			:patient_attributes => { :organization_id => Hospital.last.organization_id } )
#		assert Hospital.first != Hospital.last
#		assert_equal s.organization_id, Hospital.last.organization_id
#	end

	test "should create case study_subject and accept_nested_attributes_for patient" do
		assert_difference( 'Patient.count', 1) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = Factory(:case_study_subject,
				:patient_attributes => Factory.attributes_for(:patient))
			assert  study_subject.is_case?
			assert !study_subject.new_record?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should NOT create non-case study_subject with patient" do
		assert_difference( 'Patient.count', 0) {
		assert_difference( "StudySubject.count", 0 ) {
			study_subject = create_study_subject(
				:patient_attributes => Factory.attributes_for(:patient))
			assert !study_subject.is_case?
			assert study_subject.errors.include?(:patient)	#	no type
			assert  study_subject.new_record?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should create patient for case study_subject" do
		assert_difference( 'Patient.count', 1) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = Factory(:case_study_subject)
			assert study_subject.is_case?
			assert !study_subject.new_record?, 
				"#{study_subject.errors.full_messages.to_sentence}"
			patient = Factory(:patient, :study_subject => study_subject)
			assert !patient.new_record?, 
				"#{patient.errors.full_messages.to_sentence}"
		} }
	end

	test "should NOT create patient for non-case study_subject" do
		assert_difference( 'Patient.count', 0) {
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject
			assert !study_subject.is_case?
			assert !study_subject.new_record?, 
				"#{study_subject.errors.full_messages.to_sentence}"
			patient = Factory.build(:patient, :study_subject => study_subject)
			patient.save	#	avoid an exception being raised
			assert patient.errors.include?(:study_subject)
		} }
	end

	test "should NOT create study_subject with empty patient" do
		assert_difference( 'Patient.count', 0) {
		assert_difference( "StudySubject.count", 0 ) {
			study_subject = create_study_subject( :patient_attributes => {})
			assert study_subject.errors.include?('patient.diagnosis_id'.to_sym)
			assert study_subject.errors.matching?('patient.diagnosis_id',"can't be blank")
			assert study_subject.errors.include?('patient.hospital_no'.to_sym)
			assert study_subject.errors.matching?('patient.hospital_no',"can't be blank")
			assert study_subject.errors.include?('patient.admit_date'.to_sym)
			assert study_subject.errors.matching?('patient.admit_date',"can't be blank")
			assert study_subject.errors.include?('patient.organization_id'.to_sym)
			assert study_subject.errors.matching?('patient.organization_id',"can't be blank")
		} }
	end

	test "should NOT destroy patient with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Patient.count',1) {
			@study_subject = Factory(:patient).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Patient.count',0) {
			@study_subject.destroy
		} }
	end

	#	Delegated patient fields
	%w( admit_date organization 
			organization_id hospital_no
		).each do |method_name|

		test "should return nil #{method_name} without patient" do
			study_subject = StudySubject.new
			assert_nil study_subject.send(method_name)
		end

		test "should return #{method_name} with patient" do
			study_subject = StudySubject.new(
				:patient_attributes => Factory.attributes_for(:patient))
			assert_not_nil study_subject.send(method_name)
		end

	end

	test "should return 'no oncologist specified' for study_subject without patient" do
		study_subject = create_study_subject.reload
		assert_nil study_subject.patient
		assert_equal '[no oncologist specified]', study_subject.admitting_oncologist
	end

	test "should return 'no oncologist specified' for study_subject with null patient#admitting_oncologist" do
		assert_difference('Patient.count',1) {
		assert_difference('StudySubject.count',1) {
			study_subject = create_patient(:admitting_oncologist => nil
				).study_subject.reload
			assert_equal '[no oncologist specified]', study_subject.admitting_oncologist
		} }
	end

	test "should return 'no oncologist specified' for study_subject with blank patient#admitting_oncologist" do
		assert_difference('Patient.count',1) {
		assert_difference('StudySubject.count',1) {
			study_subject = create_patient(:admitting_oncologist => ''
				).study_subject.reload
			assert_equal '[no oncologist specified]', study_subject.admitting_oncologist
		} }
	end

	test "should return admitting_oncologist for study_subject with patient#admitting_oncologist" do
		assert_difference('Patient.count',1) {
		assert_difference('StudySubject.count',1) {
			study_subject = create_patient(:admitting_oncologist => 'Dr Jim'
				).study_subject.reload
			assert_equal 'Dr Jim', study_subject.admitting_oncologist
		} }
	end

	test "should set study_subject.reference_date to self.patient.admit_date on create" do
		create_case_study_subject_with_patient
	end

	test "should update all matching study_subjects' reference date " <<
			"with updated admit date" do
		study_subject = create_case_study_subject(
#			:matchingid => '012345',	#	seriously? set the subjecid
			:subjectid => '012345',
			:patient_attributes    => Factory.attributes_for(:patient)).reload
		other   = create_study_subject( :matchingid => '012345' )
		nobody  = create_study_subject( :matchingid => '054321' )
#	admit_date is now required, so will exist initially
#		assert_nil study_subject.reference_date
#		assert_nil study_subject.patient.admit_date
#		assert_nil other.reference_date
		assert_nil nobody.reference_date
		study_subject.patient.update_attributes(
			:admit_date => Date.yesterday )
		assert_not_nil study_subject.patient.admit_date
		assert_not_nil study_subject.reload.reference_date
		assert_not_nil other.reload.reference_date
		assert_nil     nobody.reload.reference_date
		assert_equal study_subject.reference_date, study_subject.patient.admit_date
		assert_equal study_subject.reference_date, other.reference_date
	end

	test "should set study_subject.reference_date to matching patient.admit_date " <<
			"on create with patient created first" do
		study_subject = create_case_study_subject_with_patient
		other   = create_study_subject( :matchingid => '012345' )
		assert_not_nil other.reload.reference_date
		assert_equal   other.reference_date, study_subject.reference_date
		assert_equal   other.reference_date, study_subject.patient.admit_date
	end

	test "should set study_subject.reference_date to matching patient.admit_date " <<
			"on create with patient created last" do
		other   = create_study_subject( :matchingid => '012345' )
		study_subject = create_case_study_subject_with_patient
		assert_not_nil other.reload.reference_date
		assert_equal   other.reference_date, study_subject.reference_date
		assert_equal   other.reference_date, study_subject.patient.admit_date
	end

#	NOTE no more nullifying.  In actuallity, shouldn't happen
#		as can't really edit matchingid or subjectid.
#	test "should nullify study_subject.reference_date if matching patient changes matchingid" do
#		other   = create_study_subject( :matchingid => '012345' )
#		study_subject = create_case_study_subject_with_patient
#		assert_not_nil other.reload.reference_date
##		study_subject.update_attributes(:matchingid => '012346')
##	matchingid is now protected
#		study_subject.matchingid = '012346'
#		study_subject.save
#		assert_nil     other.reload.reference_date
#	end
#
#	test "should nullify study_subject.reference_date if matching patient nullifies matchingid" do
#		other   = create_study_subject( :matchingid => '012345' )
#		study_subject = create_case_study_subject_with_patient
#		assert_not_nil other.reload.reference_date
##		study_subject.update_attributes(:matchingid => nil)
##	matchingid is now protected
#		study_subject.matchingid = nil
#		study_subject.save
#		assert_nil     other.reload.reference_date
#	end

	test "should NOT nullify study_subject.reference_date on create if no patient" do
		other   = create_study_subject( 
			:reference_date => Date.current,
			:matchingid     => '012345' )
		other.reload
		assert_not_nil other.reference_date
	end

#	admit_date is now required, so can't nullify admit_date
#	test "should nullify study_subject.reference_date if matching patient nullifies admit_date (admit_date now required)" do
#		other   = create_study_subject( :matchingid => '012345' )
#		study_subject = create_case_study_subject_with_patient
#		assert_not_nil study_subject.patient.admit_date
#		assert_not_nil study_subject.reference_date
#		assert_not_nil other.reload.reference_date
##	This actually now returns false
#		assert !study_subject.patient.update_attributes(:admit_date => nil)
#		assert_not_nil study_subject.patient.reload.admit_date
#		assert_not_nil study_subject.reference_date
#		assert_not_nil other.reload.reference_date
##		assert_nil     other.reload.reference_date
#	end

protected

#	def create_study_subject_with_matchingid(matchingid='12345')
##		study_subject = create_study_subject( 
##			:identifier_attributes => Factory.attributes_for(:identifier,
##				{ :matchingid => matchingid })).reload
#		study_subject = create_study_subject( :matchingid => matchingid ).reload
#	end

	#	Used more than once so ...
	#	And the case ALWAYS has '012345' for subjectid/matchingid
	def create_case_study_subject_with_patient
		study_subject = create_case_study_subject( 
			:subjectid => '012345',		#	NOTE set subjectid instead
			:patient_attributes    => Factory.attributes_for(:patient,
				{ :admit_date => Date.yesterday })).reload
		assert_not_nil study_subject.patient.admit_date
		assert_not_nil study_subject.reference_date
		assert_equal study_subject.reference_date, study_subject.patient.admit_date
		study_subject
	end

end
