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

#######################################################################
##
##		BEGIN DUPLICATE CHECKING TESTS
##
#
##	Case subjects: Have the same hospital_no (patient.hospital_no) as the new subject
##	Only cases have a patient record, so not explicit check for Case is done.
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate hospital_no and #{cu} login" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} })
#			end
#			# these share the same factory which means that the organization_id 
#			# is the same so the hospital_no won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'Match Found')
#			end
#			# these share the same factory which means that the organization_id 
#			# is the same so the hospital_no won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_not_nil flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			# these share the same factory which means that the organization_id 
#			# is the same so the hospital_no won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'Match Found', :duplicate_id => subject.id )
#			} }
#			assert !assigns(:duplicates).empty?
#			# these share the same factory which means that the organization_id 
#			# is the same so the hospital_no won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_not_nil flash[:notice]
#			assert_redirected_to subject
#		end
#
#		test "should create nonwaivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'No Match'" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			minimum_nonwaivered_successful_creation( 
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'No Match' )
#			assert !assigns(:duplicates)
#			# these share the same factory which means that the organization_id 
#			# is the same so the hospital_no won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#		end
#
##	Case subjects:  Are admitted the same admit date (patients.admit_date) at the same institution (patients.organization_id)
##	Only cases have a patient record, so not explicit check for Case is done.
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id and #{cu} login" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { :patient_attributes => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} })
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} }, :commit => 'Match Found' )
#			end
#			assert_not_nil flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} }, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} }, :commit => 'Match Found', :duplicate_id => subject.id )
#			} }
#			assert !assigns(:duplicates).empty?
#			assert assigns(:study_subject)
#			assert_not_nil flash[:notice]
#			assert_redirected_to subject
#		end
#
#		test "should create nonwaivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'No Match'" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			minimum_nonwaivered_successful_creation(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} }, :commit => 'No Match' )
#			assert !assigns(:duplicates)
#		end
#
##	Have the same birth date (dob) and sex (subject.sex) as the new subject and 
##		(same mother’s maiden name or existing mother’s maiden name is null)
#
##	NOTE This could include non-case subjects
##	Added this to test the view.
##	I could do all of the following duplicate tests for the 2 factories ...
##		complete_control_study_subject and complete_nonwaivered_case_study_subject
##	Seems a bit excessive though.
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing control duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login" do
#			subject = Factory(:complete_control_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login and 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'Match Found')
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login and 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login and 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'Match Found', :duplicate_id => subject.id )
#			} }
#			assert !assigns(:duplicates).empty?
#			assert assigns(:study_subject)
#			assert_not_nil flash[:notice]
#			assert_redirected_to subject
#		end
#
#		test "should create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login and 'No Match'" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			minimum_nonwaivered_successful_creation(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'No Match')
#			assert !assigns(:duplicates)
#		end
#
##	add mother's maiden name match
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login and 'Match Found' without duplicate_id" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found')
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login and 'Match Found' with invalid duplicate_id" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login and 'Match Found' with valid duplicate_id" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found', :duplicate_id => subject.id )
#			} }
#			assert !assigns(:duplicates).empty?
#			assert assigns(:study_subject)
#			assert_not_nil flash[:notice]
#			assert_redirected_to subject
#		end
#
#		test "should create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login and 'No Match'" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			minimum_nonwaivered_successful_creation(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'No Match')
#			assert !assigns(:duplicates)
#		end
#
##	existing mother's maiden name null
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login and 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found')
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login and 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login and 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_nonwaivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found', :duplicate_id => subject.id )
#			} }
#			assert !assigns(:duplicates).empty?
#			assert assigns(:study_subject)
#			assert_not_nil flash[:notice]
#			assert_redirected_to subject
#		end
#
#		test "should create nonwaivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login and 'No Match'" do
#			subject = Factory(:complete_nonwaivered_case_study_subject)
#			login_as send(cu)
#			minimum_nonwaivered_successful_creation(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'No Match')
#			assert !assigns(:duplicates)
#		end
#
##
##		END DUPLICATE CHECKING TESTS
##
#######################################################################

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

#			#	verified_on is a Time so can really only compare the date
#			#	also seems that active record uses UTC times, so
#			assert_equal addressing.verified_on.localtime.to_date, Date.today
#	Actually just a date now
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

#			#	verified_on is a Time so can really only compare the date
#			#	also seems that active record uses UTC times, so
#			assert_equal phone_number.verified_on.localtime.to_date, Date.today
#	Actually just a date now
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

#protected
#
#	def minimum_nonwaivered_form_attributes(options={})
#		{ 'study_subject' => Factory.attributes_for(:minimum_nonwaivered_form_attributes
#			) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
#	end
#
#	def nonwaivered_form_attributes(options={})
#		{ 'study_subject' => Factory.attributes_for(:nonwaivered_form_attributes
#				) }.deep_stringify_keys.deep_merge(options.deep_stringify_keys)
#	end
#
#	def full_successful_creation(options={})
#		successful_raf_creation { 
#			post :create, complete_case_study_subject_attributes(options) }
#			#	waivered / nonwaivered? does it matter?
#	end
#
#	def nonwaivered_successful_creation(options={})
#		successful_raf_creation { 
#			post :create, nonwaivered_form_attributes(options) }
#	end
#
#	def minimum_successful_creation(options={})
##		assert_difference('SubjectRace.count',count){
#		assert_difference('SubjectLanguage.count',0){
#		assert_difference('PhoneNumber.count',0){
#		assert_difference('Addressing.count',1){
#		assert_difference('Address.count',1){
#		assert_difference('Enrollment.count',2){	#	both child and mother
#		assert_difference('Patient.count',1){
#		assert_difference('StudySubject.count',2){
#			post :create, minimum_nonwaivered_form_attributes(options)
#		} } } } } } } #}
#		assert_nil flash[:error]
#		assert_redirected_to assigns(:study_subject)
#	end
#
#	def assert_duplicates_found_and_rerendered_new
#		assert !assigns(:duplicates).empty?
#		assert assigns(:study_subject)
#		assert_not_nil flash[:error]
#		assert_response :success
#		assert_template 'new'
#	end
#
end
