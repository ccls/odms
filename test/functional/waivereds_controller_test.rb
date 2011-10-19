require 'test_helper'

class WaiveredsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'StudySubject',
		:actions => [:new]
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_editors.each do |cu|

		test "should create waivered case study_subject with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should create waivered case study_subject with minimum requirements and #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
#puts assigns(:study_subject).pii.inspect
#<Pii id: 4, study_subject_id: 29, first_name: nil, middle_name: nil, last_name: nil, dob: "1989-10-03", died_on: nil, mother_first_name: nil, mother_middle_name: nil, mother_maiden_name: nil, mother_last_name: nil, father_first_name: nil, father_middle_name: nil, father_last_name: nil, email: nil, created_at: "2011-10-18 22:32:47", updated_at: "2011-10-18 22:32:47", guardian_first_name: nil, guardian_middle_name: nil, guardian_last_name: nil, guardian_relationship_id: nil, guardian_relationship_other: nil, mother_race_id: nil, father_race_id: nil, maiden_name: nil, generational_suffix: nil, father_generational_suffix: nil, birth_year: nil>
#puts assigns(:study_subject).patient.inspect
#<Patient id: 4, study_subject_id: 29, diagnosis_date: nil, diagnosis_id: nil, organization_id: nil, created_at: "2011-10-18 22:32:47", updated_at: "2011-10-18 22:32:47", admit_date: nil, treatment_began_on: nil, sample_was_collected: nil, admitting_oncologist: nil, was_ca_resident_at_diagnosis: nil, was_previously_treated: nil, was_under_15_at_dx: nil, raf_zip: nil, raf_county: nil>
#puts assigns(:study_subject).identifier.inspect
#<Identifier id: 29, study_subject_id: 29, childid: 15, patid: "0015", case_control_type: "C", orderno: 0, lab_no: nil, related_childid: nil, related_case_childid: nil, ssn: "000000025", subjectid: "603995", created_at: "2011-10-18 22:32:47", updated_at: "2011-10-18 22:32:47", matchingid: "603995", familyid: "603995", state_id_no: "25", hospital_no: nil, childidwho: nil, studyid: nil, newid: nil, gbid: "25", lab_no_wiemels: "25", idno_wiemels: "25", accession_no: "25", studyid_nohyphen: nil, studyid_intonly_nohyphen: nil, icf_master_id: "14", state_registrar_no: "25", local_registrar_no: "25">
		end

		test "should create waivered case study_subject with complete attributes and #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',1){					#	TODO should be 2 with mother
			assert_difference('Enrollment.count',1){
			assert_difference('PhoneNumber.count',1){
			assert_difference('Addressing.count',1){
			assert_difference('Address.count',1){
					post :create, :study_subject => complete_case_study_subject_attributes
			} } } } } } } } } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal '0', assigns(:study_subject).identifier.orderno.to_s
		end

		test "should create waivered case study_subject with waivered attributes and #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',1){	#	TODO should be 2 with mother
			assert_difference('Enrollment.count',1){
			assert_difference('PhoneNumber.count',1){
			assert_difference('Addressing.count',1){
			assert_difference('Address.count',1){
				post :create, :study_subject => waivered_form_attributes
			} } } } } } } } } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal '0', assigns(:study_subject).identifier.orderno.to_s
		end

		test "should create mother on create with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_not_nil assigns(:study_subject).mother
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should not assign icf_master_id to mother if none exist on create with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should not assign icf_master_id to mother if one exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should assign icf_master_id to mother if two exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456780')
			Factory(:icf_master_id,:icf_master_id => '123456781')
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_not_nil assigns(:study_subject).identifier.icf_master_id
			assert_equal '123456780', assigns(:study_subject).identifier.icf_master_id
			assert_not_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_equal '123456781', assigns(:study_subject).mother.identifier.icf_master_id
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should not assign icf_master_id if none exist on create with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_nil assigns(:study_subject).identifier.icf_master_id
			assert_not_nil flash[:warn]
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should assign icf_master_id if any exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			assert_difference('Pii.count',1){	#	TODO 2 when mother is correctly created
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_waivered_form_attributes
			} } } }
			assert_not_nil assigns(:study_subject).identifier.icf_master_id
			assert_equal '123456789', assigns(:study_subject).identifier.icf_master_id
			#	only one icf_master_id so mother will raise warning
			assert_not_nil flash[:warn]	
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should NOT create waivered case study_subject with invalid study_subject and #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				post :create, :study_subject => complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create waivered case study_subject when save fails with #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				post :create, :study_subject => complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should rollback when assign_icf_master_id raises error with #{cu} login" do
pending	#	TODO
		end

		test "should rollback when create_mother raises error with #{cu} login" do
pending	#	TODO
		end

	end

	non_site_editors.each do |cu|

		test "should NOT create waivered case study_subject with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, :study_subject => complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT create waivered case study_subject without login" do
		assert_all_differences(0) do
			post :create, :study_subject => complete_case_study_subject_attributes
		end
		assert_redirected_to_login
	end

protected

	def minimum_waivered_form_attributes(options={})
		{
			"pii_attributes"=>{
				"dob"=> Date.jd(2440000+rand(15000))
			}, 
			"identifier_attributes"=> { },
			"patient_attributes"=>{
#				"admit_date"=>"", 		#	TODO required
				"organization_id"=> Organization.first.id
			}
		}.deep_merge(options)
	end

	def waivered_form_attributes(options={})
		{
			"subject_languages_attributes"=>{
				"0"=>{"language_id"=>"1"}, 
				"1"=>{"language_id"=>""}, 
				"2"=>{"language_id"=>"", "other"=>""}
			}, 
			"sex"=>"M", 
			"identifier_attributes"=>{ }, 
			"pii_attributes"=>{
				"dob"=> Date.jd(2440000+rand(15000)), 
				"first_name"=>"", 
				"middle_name"=>"", 
				"last_name"=>"", 
				"mother_first_name"=>"", 
				"mother_middle_name"=>"", 
				"mother_last_name"=>"", 
				"mother_maiden_name"=>"", 
				"father_first_name"=>"", 
				"father_middle_name"=>"", 
				"father_last_name"=>"", 
				"guardian_relationship_id"=>"", 
				"guardian_relationship_other"=>"", 
				"guardian_first_name"=>"",
				"guardian_middle_name"=>"", 
				"guardian_last_name"=>""
			}, 
			"addressings_attributes"=>{
				"0"=>{"current_address"=>"1", 
					"address_attributes"=> Factory.attributes_for(:address,
						"address_type_id"=>"1"    # hard coded in forms	#	TODO perhaps put in controller instead of the view
					)
				}
			},
			"phone_numbers_attributes"=>{
				"0"=>{"phone_number"=>"1234567890"}, 
				"1"=>{"phone_number"=>""}
			}, 
			"enrollments_attributes"=>{
#	consented does not have a default value, so can send nothing if one button not checked
#	TODO add consented field
				"0"=>{
					"other_refusal_reason"=>"", 
					"project_id"=> Project['phase5'].id,	#"7", 
					"consented_on"=>"", 
					"document_version_id"=>"", 
					"refusal_reason_id"=>""
				}
			}, 
			"patient_attributes"=>{
				"raf_zip" => '12345',
				"raf_county" => "some county, usa",
				"was_previously_treated"=>"false", 
				"admitting_oncologist"=>"", 
				"was_under_15_at_dx"=>"true", 
				"admit_date"=>"", 
				"organization_id"=> Organization.first.id,
				"diagnosis_id"=>"", 
				"was_ca_resident_at_diagnosis"=>"true"
			}
		}.deep_merge(options)
	end

end
