require 'test_helper'

class NonwaiveredsControllerTest < ActionController::TestCase

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

		test "should create nonwaivered case study_subject with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
			} } } }
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should create nonwaivered case study_subject with complete attributes and #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',2){
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

		test "should create nonwaivered case study_subject with minimum non-waivered attributes and #{cu} login" do
#	TODO remove attributes from minimum_nonwaivered_form_attributes
			login_as send(cu)
			assert_difference('StudySubject.count',2){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
			} } } }
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal '0', assigns(:study_subject).identifier.orderno.to_s
		end

		test "should create nonwaivered case study_subject with non-waivered attributes and #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',2){
			assert_difference('Enrollment.count',1){
			assert_difference('PhoneNumber.count',1){
			assert_difference('Addressing.count',1){
			assert_difference('Address.count',1){
				post :create, :study_subject => nonwaivered_form_attributes
			} } } } } } } } } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal '0', assigns(:study_subject).identifier.orderno.to_s
		end

		test "should create mother on create with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
			} } } }
			assert_not_nil assigns(:study_subject).mother
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should not assign icf_master_id to mother if none exist on create with #{cu} login" do
			login_as send(cu)
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
			} } } }
			assert_nil assigns(:study_subject).mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should not assign icf_master_id to mother if one exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
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
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
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
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
			} } } }
			assert_nil assigns(:study_subject).identifier.icf_master_id
			assert_not_nil flash[:warn]
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should assign icf_master_id if any exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			assert_difference('Pii.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('StudySubject.count',2){
				post :create, :study_subject => minimum_nonwaivered_form_attributes
			} } } }
			assert_not_nil assigns(:study_subject).identifier.icf_master_id
			assert_equal '123456789', assigns(:study_subject).identifier.icf_master_id
			#	only one icf_master_id so mother will raise warning
			assert_not_nil flash[:warn]	
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
		end

		test "should set consented to 1 if consented_on not blank and #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',2){
			assert_difference('Enrollment.count',1){
			assert_difference('PhoneNumber.count',1){
			assert_difference('Addressing.count',1){
			assert_difference('Address.count',1){
				post :create, :study_subject => nonwaivered_form_attributes({
					"enrollments_attributes"=>{ "0"=>{ "consented_on"=> Date.today } }
				})
			} } } } } } } } } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal 'C', assigns(:study_subject).identifier.case_control_type
			assert_equal  0 , assigns(:study_subject).identifier.orderno
			assert_equal  1 , assigns(:study_subject).enrollments.first.consented
		end

		test "should copy addressing address county to patient county with #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',2){
			assert_difference('Enrollment.count',1){
			assert_difference('PhoneNumber.count',1){
			assert_difference('Addressing.count',1){
			assert_difference('Address.count',1){
				post :create, :study_subject => nonwaivered_form_attributes({
					"addressings_attributes"=>{ "0"=>{ "address_attributes"=> { :county => 'Alameda' } } }
				})
			} } } } } } } } } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal         1, assigns(:study_subject).addresses.length
			assert_equal 'Alameda', assigns(:study_subject).addresses.first.county
			assert_equal 'Alameda', assigns(:study_subject).reload.patient.raf_county
		end

		test "should copy addressing address zip to patient zip with #{cu} login" do
			login_as send(cu)
			assert_difference('StudySubject.count',2){
#			assert_difference('SubjectRace.count',count){
			assert_difference('SubjectLanguage.count',1){
			assert_difference('Identifier.count',2){
			assert_difference('Patient.count',1){
			assert_difference('Pii.count',2){
			assert_difference('Enrollment.count',1){
			assert_difference('PhoneNumber.count',1){
			assert_difference('Addressing.count',1){
			assert_difference('Address.count',1){
				post :create, :study_subject => nonwaivered_form_attributes({
					"addressings_attributes"=>{ "0"=>{ "address_attributes"=> { :zip => '54321' } } }
				})
			} } } } } } } } } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_equal       1, assigns(:study_subject).addresses.length
			assert_equal '54321', assigns(:study_subject).addresses.first.zip
			assert_equal '54321', assigns(:study_subject).reload.patient.raf_zip
		end

		test "should NOT create nonwaivered case study_subject with invalid study_subject and #{cu} login" do
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

		test "should NOT create nonwaivered case study_subject when save fails with #{cu} login" do
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

#		test "should rollback when assign_icf_master_id raises error with #{cu} login" do
#pending # TODO should test when assign_icf_master_id fails
#		end 
#
#		test "should rollback when create_mother raises error with #{cu} login" do
#pending # TODO should test when create_mother fails
#		end 

	end

	non_site_editors.each do |cu|

		test "should NOT create nonwaivered case study_subject with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, :study_subject => complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT create nonwaivered case study_subject without login" do
		assert_all_differences(0) do
			post :create, :study_subject => complete_case_study_subject_attributes
		end
		assert_redirected_to_login
	end

protected

	def minimum_nonwaivered_form_attributes(options={})
#	TODO require hospital_no
		{
			"identifier_attributes" => { }, 
			"pii_attributes"        => Factory.attributes_for(:pii),
			"patient_attributes"    => Factory.attributes_for(:patient)
		}.deep_merge(options)
	end

	def nonwaivered_form_attributes(options={})
		{
#	NOT ACTUALLY ON THE FORM
#			"subject_races_attributes"=>{"0"=>{"race_id"=>"1"}},
			"subject_languages_attributes"=>{"0"=>{"language_id"=>"1"}, "1"=>{"language_id"=>""}}, 
			"sex"=>"M", 
			"identifier_attributes"=>{ }, 
			"pii_attributes"=> Factory.attributes_for(:pii, {
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
			}), 
			"addressings_attributes"=>{
				"0"=>{
					"address_attributes"=> Factory.attributes_for(:address)
				}
			}, 
			"enrollments_attributes"=>{
				"0"=>{
					"consented_on"=>"", 
					"document_version_id"=>""}
			}, 
			"phone_numbers_attributes"=>{
				"0"=>{"phone_number"=>"1234567890" }, 
				"1"=>{"phone_number"=>""}
			}, 
			"patient_attributes"=> Factory.attributes_for(:patient,{
				"sample_was_collected"=>"1",				
				"was_previously_treated"=>"false", 
				"admitting_oncologist"=>"", 
				"was_under_15_at_dx"=>"true", 
				"diagnosis_id"=>"", 
				"was_ca_resident_at_diagnosis"=>"true"
			})
		}.deep_merge(options)
	end

end
