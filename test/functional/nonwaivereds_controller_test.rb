require 'test_helper'

class NonwaiveredsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'Subject',
		:actions => [:new, :create],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_subject
	}
	def factory_attributes(options={})
#			:subject_type_id => SubjectType['Case'].id,
#			:race_ids => [Race.random.id]
		Factory.attributes_for(:subject,{
			'identifier_attributes' => Factory.attributes_for(:identifier)
		}.merge(options))
	end

	assert_access_with_login({
		:logins => site_editors })

	assert_no_access_with_login({
		:logins => non_site_editors })

	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

	site_editors.each do |cu|

		test "should create nonwaivered case subject with #{cu} login" do
			login_as send(cu)
			assert_difference('Identifier.count',1){
			assert_difference('Subject.count',1){
#			assert_difference('SubjectRace.count',1){
				post :create, :subject => factory_attributes
			} } #}
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
		end

		test "should create nonwaivered case subject with complete attributes and #{cu} login" do
			login_as send(cu)
			assert_all_differences(1) do
				post :create, :subject => complete_case_subject_attributes
			end
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
			assert_equal 'C', assigns(:subject).identifier.case_control_type
			assert_equal  0 , assigns(:subject).identifier.orderno
		end

		test "should create nonwaivered case subject with non-waivered attributes and #{cu} login" do
			login_as send(cu)
			assert_all_differences(1) do
				post :create, :subject => nonwaivered_form_attributes
			end
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
			assert_equal 'C', assigns(:subject).identifier.case_control_type
			assert_equal  0 , assigns(:subject).identifier.orderno
		end

		test "should set consented to 1 if consented_on not blank and #{cu} login" do
			login_as send(cu)
			assert_all_differences(1) do
				post :create, :subject => nonwaivered_form_attributes({
					"enrollments_attributes"=>{ "0"=>{ "consented_on"=> Date.today } }
				})
			end
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
			assert_equal 'C', assigns(:subject).identifier.case_control_type
			assert_equal  0 , assigns(:subject).identifier.orderno
			assert_equal  1 , assigns(:subject).enrollments.first.consented
		end

		test "should copy addressing address county to patient county with #{cu} login" do
#	still need to figure out county / county_id stuff
			login_as send(cu)
			assert_all_differences(1) do
				post :create, :subject => nonwaivered_form_attributes({
#					"addressings_attributes"=>{ "0"=>{ "address_attributes"=> { :zip => 12345 } } }
				})
			end
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
pending
		end

		test "should copy addressing address zip to patient zip with #{cu} login" do
			login_as send(cu)
			assert_all_differences(1) do
				post :create, :subject => nonwaivered_form_attributes({
					"addressings_attributes"=>{ "0"=>{ "address_attributes"=> { :zip => '54321' } } }
				})
			end
			assert_nil flash[:error]
			assert_redirected_to assigns(:subject)
			assert_equal       1, assigns(:subject).addresses.length
			assert_equal '54321', assigns(:subject).addresses.first.zip
			assert_equal '54321', assigns(:subject).reload.patient.raf_zip
		end

		test "should NOT create nonwaivered case subject with invalid subject and #{cu} login" do
			login_as send(cu)
			Subject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				post :create, :subject => complete_case_subject_attributes
			end
			assert assigns(:subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create nonwaivered case subject when save fails with #{cu} login" do
			login_as send(cu)
			Subject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				post :create, :subject => complete_case_subject_attributes
			end
			assert assigns(:subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT create nonwaivered case subject with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, :subject => complete_case_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT create nonwaivered case subject without login" do
		assert_all_differences(0) do
			post :create, :subject => complete_case_subject_attributes
		end
		assert_redirected_to_login
	end

protected

	def nonwaivered_form_attributes(options={})
		{
#	NOT ACTUALLY ON THE FORM
#			"subject_races_attributes"=>{"0"=>{"race_id"=>"1"}},
			"subject_languages_attributes"=>{"0"=>{"language_id"=>"1"}, "1"=>{"language_id"=>""}}, 
			"subject_type_id"=>"1", 
			"sex"=>"M", 
			"identifier_attributes"=> Factory.attributes_for(:identifier),
#	won't work until patid and childid are auto-generated
#			"identifier_attributes"=>{
#				"hospital_no"=>""
#			}, 
			"pii_attributes"=>{
				"first_name"=>"FIRSTNAME", 
				"middle_name"=>"", 
				"last_name"=>"LASTNAME", 
				"dob"=> Date.jd(2440000+rand(15000)),
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
				"0"=>{
					"current_address"=>"1", 
					"address_attributes"=> Factory.attributes_for(:address,
						"address_type_id"=>"1"		#	hard coded in forms
					)
				}
			}, 
			"enrollments_attributes"=>{
				"0"=>{"project_id"=>"7", "consented_on"=>"", "document_version_id"=>""}
			}, 
			"phone_numbers_attributes"=>{
				"0"=>{"phone_number"=>"1234567890"}, "1"=>{"phone_number"=>""}
			}, 
			"patient_attributes"=>{
				"sample_was_collected"=>"1",				
				"was_previously_treated"=>"false", 
				"admitting_oncologist"=>"", 
				"was_under_15_at_dx"=>"true", 
				"admit_date"=>"", 
				"organization_id"=>"", 
				"diagnosis_id"=>"", 
				"was_ca_resident_at_diagnosis"=>"true"
			}
		}.deep_merge(options)
	end

end
