require 'test_helper'
require 'raf_test_helper'

class CasesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model   => 'StudySubject',
		:actions => [:new]
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

#	index won't work here yet as is a search

#
#	This is too unconventional for any of this to work.
#
#	ASSERT_ACCESS_OPTIONS = { 
#		:model   => 'StudySubject',
#		:actions => [:new,:show,:index],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_study_subject
#	}
#	def factory_attributes(options={})
#		Factory.attributes_for(:study_subject,options)
#	end
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login


#
#	"new" will now be a full form
#	"create" will no longer redirect to a RAF
#	"show" will be added
#	"edit" will be added
#	"update" will be added
#
#	possibly be able to use "generic" stuff
#

	site_editors.each do |cu|

		test "should get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should return nothing without matching patid and #{cu} login" do
			login_as send(cu)
			get :index, :q => 'NOPE'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:NOPE/,
				flash[:error]
		end

		test "should return nothing without matching icf master id and #{cu} login" do
			login_as send(cu)
			get :index, :q => 'donotmatch'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:donotmatch/,
				flash[:error]
		end

		test "should return case study_subject with matching patid and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			get :index, :q => case_study_subject.patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should return case study_subject with matching patid missing" <<
				" leading zeroes and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			# case_study_subject.patid should be a small 4-digit string
			#   with leading zeroes. (probably 0001). Remove them before submit.
			patid = case_study_subject.patid.to_i
			assert patid < 1000,
				'Expected auto-generated patid to be less than 1000 for this test'
			get :index, :q => patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should return case study_subject with matching icf master id and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject,
				:icf_master_id => '12345')
			get :index, :q => case_study_subject.icf_master_id
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end








#		test "should get new with #{cu} login" do
#			login_as send(cu)
#			get :new
#			assert_not_nil assigns(:study_subject)
#			assert_response :success
#			assert_template 'new'
#		end





#		test "should post new case and redirect to waivered with #{cu} login" do
#			login_as send(cu)
#			hospital = Hospital.active.waivered.first
#			post :create, { "hospital_id"=> hospital.id }					#		TODO will need changed
#			assert_redirected_to new_waivered_path("study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> hospital.organization_id }})
#		end
#
#		test "should post new case and redirect to nonwaivered with #{cu} login" do
#			login_as send(cu)
#			hospital = Hospital.active.nonwaivered.first
#			post :create, { "hospital_id"=> hospital.id }					#		TODO will need changed
#			assert_redirected_to new_nonwaivered_path("study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> hospital.organization_id }})
#		end
#
#		test "should not post new case without hospital_id and #{cu} login" do
#			login_as send(cu)
#			post :create
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end
#
#		test "should not post new case without valid hospital_id and #{cu} login" do
#			login_as send(cu)
#			post :create, { "hospital_id"=> '0' }					#		TODO will need changed
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end



		test "should create new case with valid waivered subject #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
		end

		test "should create new case with valid nonwaivered subject #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
		end

		test "should NOT create new case with invalid subject #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				post :create, minimum_nonwaivered_form_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create new case with failed subject save #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				post :create, minimum_nonwaivered_form_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end





		test "should show case with valid case id #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'show'
		end

		test "should NOT show control with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT show mother with #{cu} login" do
			study_subject = Factory(:mother_study_subject)
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

		test "should edit case with #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit mother with #{cu} login" do
			study_subject = Factory(:mother_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT edit control with #{cu} login" do
			study_subject = Factory(:control_study_subject)
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

		test "should update case with #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to case_path(study_subject)
		end

		test "should NOT update mother with #{cu} login" do
			study_subject = Factory(:mother_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT update control with #{cu} login" do
			study_subject = Factory(:control_study_subject)
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
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'addressings_attributes' => { 
#					0 => Factory.attributes_for(:addressing) }
					'0' => { "address_attributes"=> Factory.attributes_for(:address) } } }
			} }
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to case_path(study_subject)
		end

		test "should update and create phone number with #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			assert_difference('PhoneNumber.count',1) {
				put :update, :id => study_subject.id, 
					:study_subject => { 'phone_numbers_attributes' => { 
					'0' => Factory.attributes_for(:phone_number) } }
			}
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to case_path(study_subject)
		end

		test "should update and create address with blank line and #{cu} login" do
pending
		end

##################################################

		test "should NOT have checked subject_languages with #{cu} login" do
			login_as send(cu)
			get :new
			assert_select( "div#study_subject_languages" ){
				assert_select( "div.languages_label" )
				assert_select( "div#languages" ){
					assert_select( "div.subject_language.creator", 3 ).each do |sl|
						#	checkbox and hidden share the same name
						assert_select( sl, "input[name=?]", /study_subject\[subject_languages_attributes\]\[\d\]\[language_id\]/, 2 )
						assert_select( sl, "input[type=hidden][value='']", 1 )
						assert_select( sl, "input[type=checkbox][value=?]", /\d/, 1 )	#	value is the language_id (could test each but iffy)
						#	should not be checked
						assert_select( sl, "input[type=checkbox][checked=checked]", 0 )
						assert_select( sl, ":not([checked=checked])" )	#	this is the important check
					end
					assert_select("div.subject_language > div#other_language > div#specify_other_language",1 ){
						assert_select("input[type=text][name=?]",/study_subject\[subject_languages_attributes\]\[\d\]\[other_language\]/)
					}
			} }
		end

		test "should create case study_subject" <<
				" with complete attributes and #{cu} login" do
			login_as send(cu)
			full_successful_creation
			assert_equal 'C', assigns(:study_subject).case_control_type
			assert_equal '0', assigns(:study_subject).orderno.to_s
		end


#	WAIVERED ONLY

		test "should create waivered case study_subject" <<
				" without complete address and #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation(
				:study_subject => { :addressings_attributes => { '0' => {
					:address_attributes => { 
						:line_1 => '', :city => '',
						:state  => '', :zip  => '' } } } } )
		end
	

	

		%w( waivered nonwaivered ).each do |w|
	
			test "should create #{w} case study_subject enrolled in ccls" <<
					" with #{cu} login" do
				login_as send(cu)
				send("minimum_#{w}_successful_creation")
				assert_equal [Project['ccls']],
					assigns(:study_subject).enrollments.collect(&:project)
			end
	
			test "should create #{w} case study_subject" <<
					" with minimum requirements and #{cu} login" do
				login_as send(cu)
				send("minimum_#{w}_successful_creation")
			end
	
			test "should add '[no address provided]' to blank line_1 if city, state, zip" <<
					" are not blank for #{w} with #{cu} login" do
				login_as send(cu)
				assert_difference('SubjectLanguage.count',0){
				assert_difference('PhoneNumber.count',0){
				assert_difference('Addressing.count',1){	#	different
				assert_difference('Address.count',1){	#	different
				assert_difference('Enrollment.count',2){	#	both child and mother
				assert_difference('Patient.count',1){
				assert_difference('StudySubject.count',2){
					post :create, send("minimum_#{w}_form_attributes",
						:study_subject => { :addressings_attributes => { '0' => {
							"address_attributes"=> Factory.attributes_for(:address, 
								:line_1 => '') } 
					} } ) 
				} } } } } } }
				assert_nil flash[:error]
				assert_redirected_to assigns(:study_subject)
				assert_not_nil assigns(:study_subject).addressings.first.address.line_1
				assert_equal '[no address provided]',
					assigns(:study_subject).addressings.first.address.line_1
			end
	
			test "should create #{w} case study_subject" <<
					" with #{cu} login and create studyid" do
				login_as send(cu)
				send("minimum_#{w}_successful_creation")
				assert_not_nil assigns(:study_subject).studyid
				assert_match /\d{4}-C-0/, assigns(:study_subject).studyid
			end
	
			test "should create #{w} case study_subject" <<
					" with valid and verified addressing and #{cu} login" do
				login_as user = send(cu)
				send("#{w}_successful_creation")
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
	
			test "should create #{w} case study_subject" <<
					" with valid and verified phone_number and #{cu} login" do
				login_as user = send(cu)
				send("#{w}_successful_creation")
				phone_number = assigns(:study_subject).phone_numbers.first
				assert phone_number.is_verified
				assert_not_nil phone_number.how_verified
				assert_equal phone_number.data_source, DataSource['RAF']
				assert_equal phone_number.current_phone, YNDK[:yes]
				assert_equal phone_number.is_valid, YNDK[:yes]
				assert_equal phone_number.verified_on, Date.today
				assert_equal phone_number.verified_by_uid, user.uid
			end
	
			test "should create #{w} case study_subject" <<
					" with primary phone_number and #{cu} login" do
				login_as send(cu)
				send("#{w}_successful_creation")
				assert_equal 1, assigns(:study_subject).phone_numbers.length
				assert assigns(:study_subject).phone_numbers.first.is_primary
			end
	
			test "should create #{w} case study_subject" <<
					" with primary first phone_number and #{cu} login" do
				login_as send(cu)
	
	#	Don't use this as wraps in count assertions and expects
	#	that only 1 PhoneNumber is created
	#	waivered_successful_creation
				post :create, send("#{w}_form_attributes",'study_subject' => {
					'phone_numbers_attributes' => {
						"0"=>{"phone_number"=>"1234567890" }, 
						"1"=>{"phone_number"=>"1234567891"}
				}})
	
				assert_equal 2, assigns(:study_subject).phone_numbers.length
				assert  assigns(:study_subject).phone_numbers[0].is_primary
				assert !assigns(:study_subject).phone_numbers[1].is_primary
			end
	
			test "should create #{w} case study_subject" <<
					" with non-primary second-only phone_number and #{cu} login" do
				login_as send(cu)
				send("#{w}_successful_creation",'study_subject' => {
					'phone_numbers_attributes' => {
						"0"=>{"phone_number"=>"" },
						"1"=>{"phone_number"=>"1234567891"}
				}})
				assert_equal 1, assigns(:study_subject).phone_numbers.length
				assert !assigns(:study_subject).phone_numbers[0].is_primary
	#			assert !assigns(:study_subject).phone_numbers[1].is_primary
			end
	
			test "should create #{w} case study_subject" <<
					" with #{w} attributes and #{cu} login" do
				login_as send(cu)
				send("#{w}_successful_creation")
				assert_equal 'C', assigns(:study_subject).case_control_type
				assert_equal '0', assigns(:study_subject).orderno.to_s
			end
	
	
	
			test "should create #{w} case study_subject" <<
					" and set is_eligible yes with #{cu} login" do
				login_as send(cu)
				send("#{w}_successful_creation")
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
	
	
	#	TODO test ineligiblity_reasons
	
			test "should create #{w} case study_subject" <<
					" and set is_eligible no with #{cu} login and over 15" do
				login_as send(cu)
				send("#{w}_successful_creation",{ 'study_subject' => {
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
	
			test "should create #{w} case study_subject" <<
					" and set is_eligible no with #{cu} login and previously treated" do
				login_as send(cu)
				send("#{w}_successful_creation",{ 'study_subject' => {
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
	
			test "should create #{w} case study_subject" <<
					" and set is_eligible no with #{cu} login and not ca resident" do
				login_as send(cu)
				send("#{w}_successful_creation",{ 'study_subject' => {
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
	
			test "should create #{w} case study_subject" <<
					" and set is_eligible no with #{cu} login and not english or spanish" do
				login_as send(cu)
				#	remove english and add another so subject_language is created
				send("#{w}_successful_creation",{ 'study_subject' => {
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
	
	
	
			test "should create mother on #{w} create with #{cu} login" do
				login_as send(cu)
				send("minimum_#{w}_successful_creation")
				assert_not_nil assigns(:study_subject).mother
			end
	
			test "should not assign icf_master_id to mother if none exist on #{w} create" <<
					" with #{cu} login" do
				login_as send(cu)
				send("minimum_#{w}_successful_creation")
				assert_nil assigns(:study_subject).mother.icf_master_id
				assert_not_nil flash[:warn]
			end
	
			test "should not assign icf_master_id to mother if one exist on #{w} create" <<
					" with #{cu} login" do
				login_as send(cu)
				Factory(:icf_master_id,:icf_master_id => '123456789')
				send("minimum_#{w}_successful_creation")
				assert_nil assigns(:study_subject).mother.icf_master_id
				assert_not_nil flash[:warn]
			end
	
			test "should assign icf_master_id to mother if two exist on #{w} create" <<
					" with #{cu} login" do
				login_as send(cu)
				Factory(:icf_master_id,:icf_master_id => '123456780')
				Factory(:icf_master_id,:icf_master_id => '123456781')
				send("minimum_#{w}_successful_creation")
				assert_not_nil assigns(:study_subject).icf_master_id
				assert_equal '123456780', assigns(:study_subject).icf_master_id
				assert_not_nil assigns(:study_subject).mother.icf_master_id
				assert_equal '123456781', assigns(:study_subject).mother.icf_master_id
			end
	
			test "should not assign icf_master_id if none exist on #{w} create" <<
					" with #{cu} login" do
				login_as send(cu)
				send("minimum_#{w}_successful_creation")
				assert_nil assigns(:study_subject).icf_master_id
				assert_not_nil flash[:warn]
			end
	
			test "should assign icf_master_id if any exist on #{w} create with #{cu} login" do
				login_as send(cu)
				Factory(:icf_master_id,:icf_master_id => '123456789')
				send("minimum_#{w}_successful_creation")
				assert_not_nil assigns(:study_subject).icf_master_id
				assert_equal '123456789', assigns(:study_subject).icf_master_id
				#	only one icf_master_id so mother will raise warning
				assert_not_nil flash[:warn]	
			end
	
	
	
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
			study_subject = Factory(:study_subject)
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
			study_subject = Factory(:study_subject)
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

		test "should send email on create with #{cu} login" do
			login_as send(cu)
			assert_difference('ActionMailer::Base.deliveries.length',1) {
				#	waivered / nonwaivered? does it matter?
				minimum_waivered_successful_creation
			}
		end






	end

	non_site_editors.each do |cu|

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

#		test "should NOT get new with #{cu} login" do
#			login_as send(cu)
#			get :new
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end

		test "should NOT post new with #{cu} login" do
			login_as send(cu)
			post :create	#, {"hospital_id"=>"0"}					#		TODO will need changed
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
			put :update, :id => 0							#	TODO MAY need to add attributes (doubt it)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

#	test "should NOT get new without login" do
#		get :new
#		assert_redirected_to_login
#	end

	test "should NOT post new without login" do
		post :create	#, {"hospital_id"=>"0"}					#		TODO will need changed
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
		put :update, :id => 0						#	TODO MAY need to add attributes (doubt it)
		assert_redirected_to_login
	end

end
__END__
