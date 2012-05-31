require 'test_helper'
require 'raf_test_helper'

class NonwaiveredsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'StudySubject',
		:actions => [:new]
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

	site_editors.each do |cu|

		test "should NOT have checked subject_languages with #{cu} login" do
			login_as send(cu)
			get :new
			assert_select( "div#study_subject_languages" ){
				assert_select( "div.languages_label" )
				assert_select( "div#languages" ){
					#	nonwaivered form ONLY has English and Spanish.  No Other or other_specify
					assert_select( "div.subject_language.creator", 2 ).each do |sl|
						#	checkbox and hidden share the same name
						assert_select( sl, "input[name=?]", /study_subject\[subject_languages_attributes\]\[\d\]\[language_id\]/, 2 )
						assert_select( sl, "input[type=hidden][value='']", 1 )
						assert_select( sl, "input[type=checkbox][value=?]", /\d/, 1 )	#	value is the language_id (could test each but iffy)
						#	should not be checked
						assert_select( sl, "input[type=checkbox][checked=checked]", 0 )
						assert_select( sl, ":not([checked=checked])" )	#	this is the important check
					end
					assert_select("div.subject_language > div#other_language",0 )
					assert_select("div.subject_language > div#other_language > div#specify_other_language",0 )
			} }
		end

		test "should create nonwaivered case study_subject enrolled in ccls" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
			assert_equal [Project['ccls']],
				assigns(:study_subject).enrollments.collect(&:project)
		end

		test "should create nonwaivered case study_subject" <<
				" with minimum requirements and #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
		end

		test "should NOT create nonwaivered case study_subject" <<
				" without complete address and #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_nonwaivered_form_attributes(
					:study_subject => { :addressings_attributes => { '0' => {
						:address_attributes => { 
							:line_1 => '', :city => '',
							:state  => '', :zip  => '' } } } } )
			end
			assert assigns(:study_subject).errors.matching?(
				'addressings.address.line_1',"can't be blank")
			assert assigns(:study_subject).errors.matching?(
				'addressings.address.city',"can't be blank")
			assert assigns(:study_subject).errors.matching?(
				'addressings.address.state',"can't be blank")
			assert assigns(:study_subject).errors.matching?(
				'addressings.address.zip',"can't be blank")
		end

		test "should add '[no address provided]' to blank line_1 if city, state, zip" <<
				" are not blank with #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation(
				:study_subject => { :addressings_attributes => { '0' => {
					"address_attributes"=> Factory.attributes_for(:address, 
						:line_1 => '') } 
			} } )
			assert_not_nil assigns(:study_subject).addressings.first.address.line_1
			assert_equal '[no address provided]',
				assigns(:study_subject).addressings.first.address.line_1
		end

		test "should create nonwaivered case study_subject" <<
				" with #{cu} login and create studyid" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
			assert_not_nil assigns(:study_subject).studyid
			assert_match /\d{4}-C-0/, assigns(:study_subject).studyid
		end

		test "should create nonwaivered case study_subject" <<
				" with complete attributes and #{cu} login" do
			login_as send(cu)
			full_successful_creation
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal '0', assigns(:study_subject).orderno.to_s
		end

		test "should create nonwaivered case study_subject" <<
				" with valid and verified addressing and #{cu} login" do
			login_as user = send(cu)
			nonwaivered_successful_creation
			addressing = assigns(:study_subject).addressings.first
			assert addressing.is_verified
			assert_not_nil addressing.how_verified
			assert_equal addressing.data_source, DataSource['RAF']
			assert_equal addressing.address_at_diagnosis, YNDK[:yes]
			assert_equal addressing.current_address, YNDK[:yes]
			assert_equal addressing.is_valid, YNDK[:yes]
			assert_equal addressing.verified_on, Date.today
			assert_equal addressing.verified_by_uid, user.uid
		end

		test "should create nonwaivered case study_subject" <<
				" with valid and verified phone_number and #{cu} login" do
			login_as user = send(cu)
			nonwaivered_successful_creation
			phone_number = assigns(:study_subject).phone_numbers.first
			assert phone_number.is_verified
			assert_not_nil phone_number.how_verified
			assert_equal phone_number.data_source, DataSource['RAF']
			assert_equal phone_number.current_phone, YNDK[:yes]
			assert_equal phone_number.is_valid, YNDK[:yes]
			assert_equal phone_number.verified_on, Date.today
			assert_equal phone_number.verified_by_uid, user.uid
		end

		test "should create nonwaivered case study_subject" <<
				" with minimum non-waivered attributes and #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal '0', assigns(:study_subject).orderno.to_s
		end

		test "should create nonwaivered case study_subject" <<
				" with non-waivered attributes and #{cu} login" do
			login_as send(cu)
			nonwaivered_successful_creation()
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal '0', assigns(:study_subject).orderno.to_s
		end

		test "should create nonwaivered case study_subject" <<
				" and set is_eligible yes with #{cu} login" do
			login_as send(cu)
			nonwaivered_successful_creation
			assert_equal YNDK[:yes], assigns(:study_subject).patient.was_under_15_at_dx
			assert_equal YNDK[:no],  assigns(:study_subject).patient.was_previously_treated
			assert_equal YNDK[:yes], assigns(:study_subject).patient.was_ca_resident_at_diagnosis
			#	assert languages include english or spanish
			assert assigns(:study_subject).language_ids.include?(Language['english'].id) or
				assigns(:study_subject).language_ids.include?(Language['spanish'].id)
			assert_equal YNDK[:yes],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible
			assert_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end


#	TODO test ineligibility_reasons

#	nonwaivered doesn't actually have a was_under_15_at_dx NO
		test "should create nonwaivered case study_subject" <<
				" and set is_eligible no with #{cu} login and over 15" do
			login_as send(cu)
			nonwaivered_successful_creation({ 'study_subject' => {
				'patient_attributes' => { 
					'was_under_15_at_dx' => YNDK[:no] } } } )
			assert_equal YNDK[:no], assigns(:study_subject).patient.was_under_15_at_dx
			assert_equal YNDK[:no],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible
			assert_not_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert !assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end

#	nonwaivered doesn't actually have a was_previously_treated YES
		test "should create nonwaivered case study_subject" <<
				" and set is_eligible no with #{cu} login and previously treated" do
			login_as send(cu)
			nonwaivered_successful_creation({ 'study_subject' => {
				'patient_attributes' => { 
					'was_previously_treated' => YNDK[:yes] } } } )
			assert_equal YNDK[:yes], assigns(:study_subject).patient.was_previously_treated
			assert_equal YNDK[:no],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible
			assert_not_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert !assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end

#	nonwaivered doesn't actually have a was_ca_resident_at_diagnosis NO
		test "should create nonwaivered case study_subject" <<
				" and set is_eligible no with #{cu} login and not ca resident" do
			login_as send(cu)
			nonwaivered_successful_creation({ 'study_subject' => {
				'patient_attributes' => { 
					'was_ca_resident_at_diagnosis' => YNDK[:no] } } } )
			assert_equal YNDK[:no], assigns(:study_subject).patient.was_ca_resident_at_diagnosis
			assert_equal YNDK[:no],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible
			assert_not_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert !assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end

#	nonwaivered doesn't actually have other language
		test "should create nonwaivered case study_subject" <<
				" and set is_eligible no with #{cu} login and not english or spanish" do
			login_as send(cu)
			#	remove english and add another so subject_language is created
			nonwaivered_successful_creation({ 'study_subject' => {
				'subject_languages_attributes' => {
					'0' => {'language_id' => '' },
					'2' => {'language_id' => Language['other'].id, 'other_language' => 'something else' }
					} } } )
			#	assert languages DO NOT include english or spanish
			assert !assigns(:study_subject).language_ids.include?(Language['english'].id) and
				!assigns(:study_subject).language_ids.include?(Language['spanish'].id)
			assert_equal YNDK[:no],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible
			assert_not_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert !assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end







		test "should create mother on create with #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
			assert_not_nil assigns(:study_subject).mother
		end

		test "should not assign icf_master_id to mother if none exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
			assert_nil assigns(:study_subject).mother.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should not assign icf_master_id to mother if one exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			minimum_nonwaivered_successful_creation
			assert_nil assigns(:study_subject).mother.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should assign icf_master_id to mother if two exist on create" <<
				" with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456780')
			Factory(:icf_master_id,:icf_master_id => '123456781')
			minimum_nonwaivered_successful_creation
			assert_not_nil assigns(:study_subject).icf_master_id
			assert_equal '123456780', assigns(:study_subject).icf_master_id
			assert_not_nil assigns(:study_subject).mother.icf_master_id
			assert_equal '123456781', assigns(:study_subject).mother.icf_master_id
		end

		test "should not assign icf_master_id if none exist on create with #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
			assert_nil assigns(:study_subject).icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should assign icf_master_id if any exist on create with #{cu} login" do
			login_as send(cu)
			Factory(:icf_master_id,:icf_master_id => '123456789')
			minimum_nonwaivered_successful_creation
			assert_not_nil assigns(:study_subject).icf_master_id
			assert_equal '123456789', assigns(:study_subject).icf_master_id
			#	only one icf_master_id so mother will raise warning
			assert_not_nil flash[:warn]	
		end

		test "should set consented to 1 if consented_on not blank and #{cu} login" do
			login_as send(cu)
			nonwaivered_successful_creation('study_subject' => {
				"enrollments_attributes"=>{ "0"=>{ "consented_on"=> Date.today } } })
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal  0 , assigns(:study_subject).orderno
			assert_equal  1 , assigns(:study_subject).enrollments.first.consented
		end

		test "should copy addressing address county to patient county" <<
				" with #{cu} login" do
			login_as send(cu)
			nonwaivered_successful_creation('study_subject' => {
				"addressings_attributes"=>{ 
					"0"=>{ "address_attributes"=> { :county => 'Alameda' } } } })
			assert_equal         1, assigns(:study_subject).addresses.length
			assert_equal 'Alameda', assigns(:study_subject).addresses.first.county
			assert_equal 'Alameda', assigns(:study_subject).reload.patient.raf_county
		end

		test "should copy addressing address zip to patient zip with #{cu} login" do
			login_as send(cu)
			nonwaivered_successful_creation('study_subject' => {
				"addressings_attributes"=>{ 
					"0"=>{ "address_attributes"=> { :zip => '54321' } } } })
			assert_equal       1, assigns(:study_subject).addresses.length
			assert_equal '54321', assigns(:study_subject).addresses.first.zip
			assert_equal '54321', assigns(:study_subject).reload.patient.raf_zip
		end

		test "should NOT create nonwaivered case study_subject" <<
				" with invalid study_subject and #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				#	waivered / nonwaivered? does it matter?
				post :create, complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create nonwaivered case study_subject" <<
				" when save fails with #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				#	waivered / nonwaivered? does it matter?
				post :create, complete_case_study_subject_attributes
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

#
#	As patid, childid and subjectid are expected to be unique,
#	I could add a unique validation, however, these values
#	are not given by the user and a failed validation would
#	be unresolvable by the user.  This should never actually
#	happen as I explicitly select unique values at creation.
#	However, just in case something might happen, I've tried
#	to deal with it in the controller.
#
		test "should raise a database error if patid exists with #{cu} login" do
			StudySubject.any_instance.stubs(:get_next_patid).returns('0123')
			study_subject = Factory(:case_study_subject)
			assert_not_nil study_subject.patid
			login_as send(cu)
			assert_all_differences(0) do
				#	waivered / nonwaivered? does it matter?
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			#	Database error.  Check production logs and contact Jake.
			assert_match /Database error/, flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should raise a database error if childid exists with #{cu} login" do
			StudySubject.any_instance.stubs(:get_next_childid).returns(12345)
			study_subject = Factory(:study_subject)	#	doesn't need to be case
			assert_not_nil study_subject.childid
			login_as send(cu)
			assert_all_differences(0) do
				#	waivered / nonwaivered? does it matter?
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			#	Database error.  Check production logs and contact Jake.
			assert_match /Database error/, flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should raise a database error if subjectid exists with #{cu} login" do
			StudySubject.any_instance.stubs(:generate_subjectid).returns('012345')
			study_subject = Factory(:study_subject)	#	doesn't need to be case
			assert_not_nil study_subject.subjectid
			login_as send(cu)
			assert_all_differences(0) do
				#	waivered / nonwaivered? does it matter?
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			#	Database error.  Check production logs and contact Jake.
			assert_match /Database error/, flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT create nonwaivered case study_subject with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				#	waivered / nonwaivered? does it matter?
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT create nonwaivered case study_subject without login" do
		assert_all_differences(0) do
			#	waivered / nonwaivered? does it matter?
			post :create, complete_case_study_subject_attributes
		end
		assert_redirected_to_login
	end

end
