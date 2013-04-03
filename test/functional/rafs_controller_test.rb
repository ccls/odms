require 'test_helper'
require 'raf_test_helper'

class RafsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'StudySubject',
		:actions => [:new]
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

	site_editors.each do |cu|

#
#	show
#

		test "should show case with valid case id #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'show'
		end

		test "should show complete case with valid case id #{cu} login" do
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'show'
		end

		test "should NOT show control with #{cu} login" do
			study_subject = FactoryGirl.create(:control_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT show mother with #{cu} login" do
			study_subject = FactoryGirl.create(:mother_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT show with invalid id #{cu} login" do
			login_as send(cu)
			get :show, :id => 0
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end








		test "should NOT have checked subject_languages on new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_select( "div#study_subject_languages" ){
				assert_select( "div.languages_label" )
				assert_select( "div#languages" ){
					assert_select( "div.subject_language.creator", 3 ).each do |sl|
						#	checkbox and hidden share the same name
						assert_select( sl, "input[name=?]", 
							/study_subject\[subject_languages_attributes\]\[\d\]\[language_code\]/, 2 )
						assert_select( sl, "input[type=hidden][value='']", 1 )
						assert_select( sl, "input[type=checkbox][value=?]", 
							/\d/, 1 )	#	value is the language_code (could test each but iffy)
						#	should not be checked
						assert_select( sl, "input[type=checkbox][checked=checked]", 0 )
						assert_select( sl, ":not([checked=checked])" )	#	this is the important check
					end
					assert_select("div.subject_language > div#other_language > div#specify_other_language",1 ){
						assert_select("input[type=text][name=?]",/study_subject\[subject_languages_attributes\]\[\d\]\[other_language\]/)
					}
			} }
		end





#
#	create
#


		test "should create case study_subject" <<
				" with complete attributes and #{cu} login" do
			login_as send(cu)
			full_successful_creation
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal '0', assigns(:study_subject).orderno.to_s
		end

		test "should create waivered case study_subject" <<
				" without complete address and #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation(
				:study_subject => { :addressings_attributes => { '0' => {
					:address_attributes => { 
						:line_1 => '', :city => '',
						:state  => '', :zip  => '' } } } } )
		end

		test "should raise inconsistency on create case study_subject" <<
				" if admit_date - dob < 15 years and was under 15 is yes" <<
				" with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					:study_subject => { 
						'dob' => '12/31/2010',
						:patient_attributes => { 
							'admit_date' => '12/31/2011',
							'was_under_15_at_dx' => YNDK[:no] }  })
			end
			assert_not_nil flash[:error]
			assert_match /Under 15 Inconsistency Found/, flash[:error]
			assert_not_nil flash[:warn]
			assert_match /Under 15 selection does not match computed value/, 
				flash[:warn]
			assert_response :success
			assert_template 'new'
		end
	
		test "should raise inconsistency on create case study_subject" <<
				" if admit_date - dob > 15 years and was under 15 is no" <<
				" with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, minimum_waivered_form_attributes(
					:study_subject => { 
						'dob' => '12/31/1990',
						:patient_attributes => { 
							'admit_date' => '12/31/2011',
							'was_under_15_at_dx' => YNDK[:yes] }  })
			end
			assert_not_nil flash[:error]
			assert_match /Under 15 Inconsistency Found/, flash[:error]
			assert_not_nil flash[:warn]
			assert_match /Under 15 selection does not match computed value/, 
				flash[:warn]
			assert_response :success
			assert_template 'new'
		end

		test "should create waivered case study_subject enrolled in ccls" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
			assert_equal [Project['ccls']],
				assigns(:study_subject).enrollments.collect(&:project)
		end

		test "should create waivered case study_subject" <<
				" with minimum requirements and #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
		end

		test "should add '[no address provided]' to blank line_1 if city, state, zip" <<
				" are not blank for waivered with #{cu} login" do
			login_as send(cu)
			assert_difference('SubjectLanguage.count',0){
			assert_difference('PhoneNumber.count',0){
			assert_difference('Addressing.count',1){	#	different
			assert_difference('Address.count',1){	#	different
			assert_difference('Enrollment.count',2){	#	both child and mother
			assert_difference('Patient.count',1){
			assert_difference('StudySubject.count',2){
				post :create, minimum_waivered_form_attributes(
					:study_subject => { :addressings_attributes => { '0' => {
						"address_attributes"=> FactoryGirl.attributes_for(:address, 
							:line_1 => '') } 
				} } ) 
			} } } } } } }
			assert_nil flash[:error]
			assert_redirected_to assigns(:study_subject)
			assert_not_nil assigns(:study_subject).addressings.first.address.line_1
			assert_equal '[no address provided]',
				assigns(:study_subject).addressings.first.address.line_1
		end

		test "should create waivered case study_subject" <<
				" with #{cu} login and create studyid" do
			login_as send(cu)
			minimum_waivered_successful_creation
			assert_not_nil assigns(:study_subject).studyid
			assert_match /\d{4}-C-0/, assigns(:study_subject).studyid
		end

		test "should create waivered case study_subject" <<
				" with valid and verified addressing and #{cu} login" do
			login_as user = send(cu)
			waivered_successful_creation
			addressing = assigns(:study_subject).addressings.first
#			assert addressing.is_verified
#			assert_not_nil addressing.how_verified
			assert_equal addressing.data_source, DataSource['RAF']
			assert_equal addressing.address_at_diagnosis, YNDK[:yes]
			assert_equal addressing.current_address, YNDK[:yes]
#			assert_equal addressing.is_valid, YNDK[:yes]
#			assert_equal addressing.verified_on, Date.current
#			assert_equal addressing.verified_by_uid, user.uid
		end

		test "should create waivered case study_subject" <<
				" with valid and verified phone_number and #{cu} login" do
			login_as user = send(cu)
			waivered_successful_creation
			phone_number = assigns(:study_subject).phone_numbers.first
#			assert phone_number.is_verified
#			assert_not_nil phone_number.how_verified
			assert_equal phone_number.data_source, DataSource['RAF']
			assert_equal phone_number.current_phone, YNDK[:yes]
#			assert_equal phone_number.is_valid, YNDK[:yes]
#			assert_equal phone_number.verified_on, Date.current
#			assert_equal phone_number.verified_by_uid, user.uid
		end


#	Added is_primary checkbox, so this auto-setting is no longer done.
#	
#			test "should create waivered case study_subject" <<
#					" with primary phone_number and #{cu} login" do
#				login_as send(cu)
#				send("waivered_successful_creation")
#				assert_equal 1, assigns(:study_subject).phone_numbers.length
#				assert assigns(:study_subject).phone_numbers.first.is_primary
#			end
#	
#			test "should create waivered case study_subject" <<
#					" with primary first phone_number and #{cu} login" do
#				login_as send(cu)
#	
#	#	Don't use this as wraps in count assertions and expects
#	#	that only 1 PhoneNumber is created
#	#	waivered_successful_creation
#				post :create, send("waivered_form_attributes",'study_subject' => {
#					'phone_numbers_attributes' => {
#						"0"=>{"phone_number"=>"1234567890" }, 
#						"1"=>{"phone_number"=>"1234567891"}
#				}})
#	
#				assert_equal 2, assigns(:study_subject).phone_numbers.length
#				assert  assigns(:study_subject).phone_numbers[0].is_primary
#				assert !assigns(:study_subject).phone_numbers[1].is_primary
#			end
#	
#			test "should create waivered case study_subject" <<
#					" with non-primary second-only phone_number and #{cu} login" do
#				login_as send(cu)
#				send("waivered_successful_creation",'study_subject' => {
#					'phone_numbers_attributes' => {
#						"0"=>{"phone_number"=>"" },
#						"1"=>{"phone_number"=>"1234567891"}
#				}})
#				assert_equal 1, assigns(:study_subject).phone_numbers.length
#				assert !assigns(:study_subject).phone_numbers[0].is_primary
#	#			assert !assigns(:study_subject).phone_numbers[1].is_primary
#			end

		test "should create waivered case study_subject" <<
				" with waivered attributes and #{cu} login" do
			login_as send(cu)
			waivered_successful_creation
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal '0', assigns(:study_subject).orderno.to_s
		end

		test "should create waivered case study_subject" <<
				" and set is_eligible yes with #{cu} login" do
			login_as send(cu)
			waivered_successful_creation
			assert_equal YNDK[:yes], assigns(:study_subject).patient.was_under_15_at_dx,
				"Should have been under 15 at dx"
			assert_equal YNDK[:no],  assigns(:study_subject).patient.was_previously_treated,
				"Should not have been previously treated"
			assert_equal YNDK[:yes], assigns(:study_subject).patient.was_ca_resident_at_diagnosis,
				"Should have been CA resident at dx"
			#	assert languages include english or spanish
#			assert assigns(:study_subject).language_ids.include?(Language['english'].id) or
#				assigns(:study_subject).language_ids.include?(Language['spanish'].id)
#
#	language_ids is actually language_codes due to custom join
#
			assert assigns(:study_subject).language_ids.include?(Language['english'].code) or
				assigns(:study_subject).language_ids.include?(Language['spanish'].code)
			assert_equal YNDK[:yes],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible,
				"Should have been marked as eligible"
			assert_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end


#	TODO test ineligiblity_reasons

		test "should create waivered case study_subject" <<
				" and set is_eligible no with #{cu} login and over 15" do
			login_as send(cu)
			waivered_successful_creation({ 'study_subject' => {
				#	something greater than 15 years ago
				'dob' => Date.jd( ((Date.current - 15.years).jd) - rand(5000)).to_s,
				'patient_attributes' => { 
					'was_under_15_at_dx' => YNDK[:no] } } } )
			assert_equal YNDK[:no], assigns(:study_subject).patient.was_under_15_at_dx,
				"Should not have been under 15 at dx"
			assert_equal YNDK[:no],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible,
				"Should not be eligible"
			assert_not_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert !assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end

		test "should create waivered case study_subject" <<
				" and set is_eligible no with #{cu} login and previously treated" do
			login_as send(cu)
			waivered_successful_creation({ 'study_subject' => {
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

		test "should create waivered case study_subject" <<
				" and set is_eligible no with #{cu} login and not ca resident" do
			login_as send(cu)
			waivered_successful_creation({ 'study_subject' => {
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

		test "should create waivered case study_subject" <<
				" and set is_eligible no with #{cu} login and not english or spanish" do
			login_as send(cu)
			#	remove english and add another so subject_language is created
			waivered_successful_creation({ 'study_subject' => {
				'subject_languages_attributes' => {
					'0' => {'language_code' => '' },
					'2' => {'language_code' => Language['other'].code, 
									'other_language' => 'something else' }
					} } } )
			#	assert languages DO NOT include english or spanish
#			assert !assigns(:study_subject).language_ids.include?(Language['english'].id) and
#				!assigns(:study_subject).language_ids.include?(Language['spanish'].id)
#
#	language_ids is actually language_codes due to custom join
#
			assert !assigns(:study_subject).language_ids.include?(Language['english'].code) and
				!assigns(:study_subject).language_ids.include?(Language['spanish'].code)
			assert_equal YNDK[:no],
				assigns(:study_subject).enrollments.find_by_project_id(
					Project['ccls'].id).is_eligible
			assert_not_nil assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).ineligible_reason_id
			assert !assigns(:study_subject).enrollments.find_by_project_id(
				Project['ccls'].id).other_ineligible_reason.blank?
		end

		test "should create mother on waivered create with #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
			assert_not_nil assigns(:study_subject).mother
		end

		test "should not assign icf_master_id to mother if none exist on waivered create" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
			assert_nil assigns(:study_subject).mother.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should not assign icf_master_id to mother if one exist on waivered create" <<
				" with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:icf_master_id,:icf_master_id => '123456789')
			minimum_waivered_successful_creation
			assert_nil assigns(:study_subject).mother.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should assign icf_master_id to mother if two exist on waivered create" <<
				" with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:icf_master_id,:icf_master_id => '123456780')
			FactoryGirl.create(:icf_master_id,:icf_master_id => '123456781')
			minimum_waivered_successful_creation
			assert_not_nil assigns(:study_subject).icf_master_id
			assert_equal '123456780', assigns(:study_subject).icf_master_id
			assert_not_nil assigns(:study_subject).mother.icf_master_id
			assert_equal '123456781', assigns(:study_subject).mother.icf_master_id
		end

		test "should not assign icf_master_id if none exist on waivered create" <<
				" with #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
			assert_nil assigns(:study_subject).icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should assign icf_master_id if any exist on waivered create with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:icf_master_id,:icf_master_id => '123456789')
			minimum_waivered_successful_creation
			assert_not_nil assigns(:study_subject).icf_master_id
			assert_equal '123456789', assigns(:study_subject).icf_master_id
			#	only one icf_master_id so mother will raise warning
			assert_not_nil flash[:warn]	
		end

		test "should NOT create case study_subject" <<
				" with invalid study_subject and #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create case study_subject when save fails" <<
				" with #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

#		test "should rollback when assign_icf_master_id raises error with #{cu} login" do
#pending	#	TODO
#		end
#
#		test "should rollback when create_mother raises error with #{cu} login" do
#pending	#	TODO
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
			study_subject = FactoryGirl.create(:case_study_subject)
			assert_not_nil study_subject.patid
			login_as send(cu)
			assert_all_differences(0) do
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
			study_subject = FactoryGirl.create(:study_subject)
			assert_not_nil study_subject.childid
			login_as send(cu)
			assert_all_differences(0) do
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
			study_subject = FactoryGirl.create(:study_subject)
			assert_not_nil study_subject.subjectid
			login_as send(cu)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			#	Database error.  Check production logs and contact Jake.
			assert_match /Database error/, flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should send email on create with #{cu} login" do
			login_as send(cu)
			assert_difference('ActionMailer::Base.deliveries.length',1) {
				minimum_waivered_successful_creation
			}
		end





#
#	edit
#


		test "should edit case with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

#
# This is very important for HTML validation!
#
		test "should edit complete case with #{cu} login" do
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit mother with #{cu} login" do
			study_subject = FactoryGirl.create(:mother_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT edit control with #{cu} login" do
			study_subject = FactoryGirl.create(:control_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT edit with invalid id #{cu} login" do
			login_as send(cu)
			get :edit, :id => 0
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end




#
#	update
#


		test "should update case with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

		test "should NOT update mother with #{cu} login" do
			study_subject = FactoryGirl.create(:mother_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT update control with #{cu} login" do
			study_subject = FactoryGirl.create(:control_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT update with invalid id #{cu} login" do
			login_as send(cu)
			put :update, :id => 0
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		#
		#	As they are not required on creation, editting could create.
		#

		test "should update and create address with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'addressings_attributes' => { 
					'0' => { "address_attributes"=> FactoryGirl.attributes_for(:address) } } }
			} }
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

		test "should update and create address with defaults and #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as user = send(cu)
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'addressings_attributes' => { 
					'0' => { "address_attributes"=> FactoryGirl.attributes_for(:address) } } }
			} }
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)

			addressing = assigns(:study_subject).addressings.first
#			assert addressing.is_verified
#			assert_not_nil addressing.how_verified
			assert_equal addressing.data_source, DataSource['RAF']
			assert_equal addressing.address_at_diagnosis, YNDK[:yes]
			assert_equal addressing.current_address, YNDK[:yes]
#			assert_equal addressing.is_valid, YNDK[:yes]
#			assert_equal addressing.verified_on, Date.current
#			assert_equal addressing.verified_by_uid, user.uid
			assert_equal addressing.address.address_type, AddressType['residence']
		end

		test "should update address with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			addressing = FactoryGirl.create(:addressing,:study_subject => study_subject)
			assert_not_equal "ihavebeenupdated", addressing.address.line_1
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'addressings_attributes' => { 
						'0' => { :id => addressing.id,
							"address_attributes"=> FactoryGirl.attributes_for(:address,
								:line_1 => "ihavebeenupdated",
								:id => addressing.address.id) 
			} } } } }
			assert_equal "ihavebeenupdated", addressing.address.reload.line_1
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

		test "should update address and not overwrite with defaults "<<
			 	"with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			addressing = FactoryGirl.create(:addressing,:study_subject => study_subject,
				:current_address => YNDK[:no],
				:address_at_diagnosis => YNDK[:no] )
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'addressings_attributes' => { 
						'0' => { :id => addressing.id } }
			} } }
			assert_not_nil assigns(:study_subject)
			addressing.reload
			assert_equal YNDK[:no], addressing.current_address
			assert_equal YNDK[:no], addressing.address_at_diagnosis
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

#			'address_attributes' => { 
#				'address_type_id'  => AddressType['residence'].id

		test "should update and create phone number with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			assert_difference('PhoneNumber.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'phone_numbers_attributes' => { 
					'0' => FactoryGirl.attributes_for(:phone_number) } }
			}
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

		test "should update and create phone number with defaults and #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as user = send(cu)
			assert_difference('PhoneNumber.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'phone_numbers_attributes' => { 
					'0' => FactoryGirl.attributes_for(:phone_number) } }
#					'0' => FactoryGirl.attributes_for(:phone_number
#						).delete_keys!(:is_valid,:is_verified) } }
			}
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)

			phone_number = assigns(:study_subject).phone_numbers.first
#			assert phone_number.is_verified
#			assert_not_nil phone_number.how_verified
			assert_equal phone_number.data_source, DataSource['RAF']
			assert_equal phone_number.current_phone, YNDK[:yes]
#			assert_equal phone_number.is_valid, YNDK[:yes]
#			assert_equal phone_number.verified_on, Date.current
#			assert_equal phone_number.verified_by_uid, user.uid
		end

		test "should update phone number with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			phone_number = FactoryGirl.create(:phone_number,:study_subject => study_subject,
				:data_source => DataSource[:raf] )
			number = phone_number.phone_number.gsub(/\D/,'')
			login_as send(cu)
			assert_difference('PhoneNumber.count',0) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'phone_numbers_attributes' => { 
						'0' => { :id => phone_number.id, :phone_number => number.reverse
			} } } }
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
			assert_not_equal phone_number.reload.phone_number, number
		end

		test "should update phone number and not overwrite with defaults with #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			phone_number = FactoryGirl.create(:phone_number,:study_subject => study_subject,
				:current_phone => YNDK[:no],
				:phone_type_id => PhoneType['mobile'].id )
			login_as send(cu)
			assert_difference('PhoneNumber.count',0) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'phone_numbers_attributes' => { 
						'0' => { :id => phone_number.id,  } }
			} }
			assert_not_nil assigns(:study_subject)
			phone_number.reload
			assert_equal YNDK[:no], phone_number.current_phone
			assert_equal PhoneType['mobile'].id, phone_number.phone_type_id
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

		test "should update and create address with blank line and #{cu} login" do
			study_subject = FactoryGirl.create(:case_study_subject)
			login_as send(cu)
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'addressings_attributes' => { 
					'0' => { "address_attributes"=> FactoryGirl.attributes_for(:address,
						:line_1 => '') } } }
			} }
			assert_not_nil assigns(:study_subject)
			assert_not_nil assigns(:study_subject).addressings.first.address.line_1
			assert_equal '[no address provided]',
				assigns(:study_subject).addressings.first.address.line_1
			assert_nil flash[:error]
			assert_redirected_to raf_path(study_subject)
		end

		test "should NOT update case study_subject" <<
				" with invalid study_subject and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:case_study_subject)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			put :update, :id => study_subject.id,
				:study_subject => {}
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update case study_subject when save fails" <<
				" with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:case_study_subject)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			put :update, :id => study_subject.id,
				:study_subject => {}
			assert assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should update and mark is_eligible yes with #{cu} login" do
			login_as send(cu)
			#	MUST BE COMPLETE AS AM ADDING PATIENT ATTRIBUTES
			study_subject = FactoryGirl.create(:complete_case_study_subject)	#	eligible? not auto-set
			enrollment = study_subject.enrollments.find_by_project_id(
				Project['ccls'].id)
			assert_nil enrollment.is_eligible
			put :update, :id => study_subject.id,
				:study_subject => {
					'dob' => '12/31/2010',
					'patient_attributes' => {
						'id' => study_subject.patient.id,
						'admit_date' => '12/31/2011',
						'was_under_15_at_dx' => YNDK[:yes],
						'was_previously_treated' => YNDK[:no],
						'was_ca_resident_at_diagnosis' => YNDK[:yes]
					},
					'subject_languages_attributes' => {
						'0' => { 'language_code' => 'notblank' }
					},
					'enrollments_attributes' => {
						'0' => { 'id' => enrollment.id }
					}
				}
			assert_blank assigns(:study_subject).errors.full_messages.to_sentence
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to raf_path(study_subject)
			assert_equal YNDK[:yes], enrollment.reload.is_eligible
		end

		test "should update and mark is_eligible no with " <<
				"over 15 and #{cu} login" do
			login_as send(cu)
			#	MUST BE COMPLETE AS AM ADDING PATIENT ATTRIBUTES
			study_subject = FactoryGirl.create(:complete_case_study_subject)	#	eligible? not auto-set
			enrollment = study_subject.enrollments.find_by_project_id(
					Project['ccls'].id)
			assert_nil enrollment.is_eligible
			put :update, :id => study_subject.id,
				:study_subject => {
					'dob' => '12/31/1990',
					'patient_attributes' => {
						'id' => study_subject.patient.id,
						'admit_date' => '12/31/2011',
						'was_under_15_at_dx' => YNDK[:no],
						'was_previously_treated' => YNDK[:no],
						'was_ca_resident_at_diagnosis' => YNDK[:yes]
					},
					'subject_languages_attributes' => {
						'0' => { 'language_code' => 'notblank' }
					},
					'enrollments_attributes' => {
						'0' => { 'id' => enrollment.id }
					}
				}
			assert_blank assigns(:study_subject).errors.full_messages.to_sentence
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to raf_path(study_subject)
			assert_equal YNDK[:no], enrollment.reload.is_eligible
		end

		test "should update and mark is_eligible no with " <<
				"previous treatment and #{cu} login" do
			login_as send(cu)
			#	MUST BE COMPLETE AS AM ADDING PATIENT ATTRIBUTES
			study_subject = FactoryGirl.create(:complete_case_study_subject)	#	eligible? not auto-set
			enrollment = study_subject.enrollments.find_by_project_id(
					Project['ccls'].id)
			assert_nil enrollment.is_eligible
			put :update, :id => study_subject.id,
				:study_subject => {
					'dob' => '12/31/2010',
					'patient_attributes' => {
						'id' => study_subject.patient.id,
						'admit_date' => '12/31/2011',
						'was_under_15_at_dx' => YNDK[:yes],
						'was_previously_treated' => YNDK[:yes],
						'was_ca_resident_at_diagnosis' => YNDK[:yes]
					},
					'subject_languages_attributes' => {
						'0' => { 'language_code' => 'notblank' }
					},
					'enrollments_attributes' => {
						'0' => { 'id' => enrollment.id }
					}
				}
			assert_blank assigns(:study_subject).errors.full_messages.to_sentence
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to raf_path(study_subject)
			assert_equal YNDK[:no], enrollment.reload.is_eligible
		end

		test "should update and mark is_eligible no with " <<
				"non-CA residence at dx and #{cu} login" do
			login_as send(cu)
			#	MUST BE COMPLETE AS AM ADDING PATIENT ATTRIBUTES
			study_subject = FactoryGirl.create(:complete_case_study_subject)	#	eligible? not auto-set
			enrollment = study_subject.enrollments.find_by_project_id(
					Project['ccls'].id)
			assert_nil enrollment.is_eligible
			put :update, :id => study_subject.id,
				:study_subject => {
					'dob' => '12/31/2010',
					'patient_attributes' => {
						'id' => study_subject.patient.id,
						'admit_date' => '12/31/2011',
						'was_under_15_at_dx' => YNDK[:yes],
						'was_previously_treated' => YNDK[:no],
						'was_ca_resident_at_diagnosis' => YNDK[:no]
					},
					'subject_languages_attributes' => {
						'0' => { 'language_code' => 'notblank' }
					},
					'enrollments_attributes' => {
						'0' => { 'id' => enrollment.id }
					}
				}
			assert_blank assigns(:study_subject).errors.full_messages.to_sentence
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to raf_path(study_subject)
			assert_equal YNDK[:no], enrollment.reload.is_eligible
		end

		test "should update and mark is_eligible no with " <<
				"no English or Spanish and #{cu} login" do
			login_as send(cu)
			#	MUST BE COMPLETE AS AM ADDING PATIENT ATTRIBUTES
			study_subject = FactoryGirl.create(:complete_case_study_subject)	#	eligible? not auto-set
			enrollment = study_subject.enrollments.find_by_project_id(
					Project['ccls'].id)
			assert_nil enrollment.is_eligible
			put :update, :id => study_subject.id,
				:study_subject => {
					'dob' => '12/31/2010',
					'patient_attributes' => {
						'id' => study_subject.patient.id,
						'admit_date' => '12/31/2011',
						'was_under_15_at_dx' => YNDK[:yes],
						'was_previously_treated' => YNDK[:no],
						'was_ca_resident_at_diagnosis' => YNDK[:yes]
					},
					'subject_languages_attributes' => {
						'0' => { 'language_code' => '' },
						'1' => { 'language_code' => '' }
					},
					'enrollments_attributes' => {
						'0' => { 'id' => enrollment.id }
					}
				}
			assert_blank assigns(:study_subject).errors.full_messages.to_sentence
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to raf_path(study_subject)
			assert_equal YNDK[:no], enrollment.reload.is_eligible
		end



		test "should raise inconsistency on update case study_subject" <<
				" if admit_date - dob < 15 years and was under 15 is yes" <<
				" with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_all_differences(0) do
				put :update, :id => study_subject.id,
					:study_subject => { 
						'dob' => '12/31/2010',
						:patient_attributes => { 
							'admit_date' => '12/31/2011',
							'was_under_15_at_dx' => YNDK[:no] }  }
			end
			assert_not_nil flash[:error]
			assert_match /Under 15 Inconsistency Found/, flash[:error]
			assert_not_nil flash[:warn]
			assert_match /Under 15 selection does not match computed value/, 
				flash[:warn]
			assert_response :success
			assert_template 'edit'
		end
	
		test "should raise inconsistency on update case study_subject" <<
				" if admit_date - dob > 15 years and was under 15 is no" <<
				" with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_all_differences(0) do
				put :update, :id => study_subject.id,
					:study_subject => { 
						'dob' => '12/31/1990',
						:patient_attributes => { 
							'admit_date' => '12/31/2011',
							'was_under_15_at_dx' => YNDK[:yes] }  }
			end
			assert_not_nil flash[:error]
			assert_match /Under 15 Inconsistency Found/, flash[:error]
			assert_not_nil flash[:warn]
			assert_match /Under 15 selection does not match computed value/, 
				flash[:warn]
			assert_response :success
			assert_template 'edit'
		end

	end


	non_site_editors.each do |cu|

		test "should NOT post new with #{cu} login" do
			login_as send(cu)
			post :create
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create case study_subject with #{cu} login" do
			login_as send(cu)
			assert_all_differences(0) do
				post :create, complete_case_study_subject_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT show with #{cu} login" do
			login_as send(cu)
			get :show, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			login_as send(cu)
			get :edit, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			login_as send(cu)
			put :update, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end


#	no login ...

	test "should NOT post new without login" do
		post :create
		assert_redirected_to_login
	end

	test "should NOT create case study_subject without login" do
		assert_all_differences(0) do
			post :create, complete_case_study_subject_attributes
		end
		assert_redirected_to_login
	end

	test "should NOT show without login" do
		get :show, :id => 0
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		get :edit, :id => 0
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		put :update, :id => 0
		assert_redirected_to_login
	end

end
__END__
