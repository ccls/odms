require 'test_helper'
require 'raf_test_helper'

class WaiveredDuplicatesControllerTest < ActionController::TestCase
	tests WaiveredsController

#######################################################################
##
##		BEGIN DUPLICATE CHECKING TESTS
##
#
##	Case subjects: Have the same hospital_no (patient.hospital_no) as the new subject
##	Only cases have a patient record, so not explicit check for Case is done.
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate hospital_no and #{cu} login" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} })
#			end
#			#	these share the same factory which means that the organization_id 
#			#	is the same so the hospital_id won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'Match Found')
#			end
#			#	these share the same factory which means that the organization_id 
#			#	is the same so the hospital_id won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			#	these share the same factory which means that the organization_id 
#			#	is the same so the hospital_id won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'Match Found', :duplicate_id => subject.id )
#			} }
#			assert !assigns(:duplicates).empty?
#			#	these share the same factory which means that the organization_id 
#			#	is the same so the hospital_id won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#			assert_not_nil flash[:notice]
#			assert_redirected_to subject
#		end
#
#		test "should create waivered case study_subject" <<
#				" with existing duplicate hospital_no" <<
#				" and #{cu} login if 'No Match'" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			minimum_waivered_successful_creation(
#					'study_subject' => { 'patient_attributes' => {
#						:hospital_no     => subject.hospital_no
#					} }, :commit => 'No Match')
#			assert !assigns(:duplicates)
#			#	these share the same factory which means that the organization_id 
#			#	is the same so the hospital_id won't be unique
#			assert !assigns(:study_subject).errors.matching?(
#				"patient.hospital_no",'has already been taken')
#		end
#
##	Case subjects:  Are admitted the same admit date (patients.admit_date) at the same institution (patients.organization_id)
##	Only cases have a patient record, so not explicit check for Case is done.
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id and #{cu} login" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} })
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} }, :commit => 'Match Found' )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
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
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_waivered_form_attributes(
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
#		test "should create waivered case study_subject" <<
#				" with existing duplicate admit_date and organization_id" <<
#				" and #{cu} login if 'No Match'" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			minimum_waivered_successful_creation(
#					'study_subject' => { 'patient_attributes' => {
#							:admit_date      => subject.admit_date,
#							:organization_id => subject.organization_id
#					} }, :commit => 'No Match' )
#			assert !assigns(:duplicates)
#		end
#
##	All subjects:  Have the same birth date (dob) and sex (subject.sex) as the new subject and 
##		(same mother’s maiden name or existing mother’s maiden name is null), or
#
#
##	NOTE This could include non-case subjects
##	Added this to test the view.
##	I could do all of the following duplicate tests for the 2 factories ...
##		complete_control_study_subject and complete_waivered_case_study_subject
##	Seems a bit excessive though.
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing control duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login" do
#			subject = Factory(:complete_control_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'Match Found' )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_waivered_form_attributes(
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
#		test "should create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank mother_maiden_names" <<
#				" and #{cu} login if 'No Match'" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			minimum_waivered_successful_creation(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob
#					}, :commit => 'No Match' )
#			assert !assigns(:duplicates)
#		end
#
##	mother's maiden name match
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names and #{cu} login" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#					:dob => subject.dob, :mother_maiden_name => 'Smith'
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#					:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found' )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#					:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_waivered_form_attributes(
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
#		test "should create waivered case study_subject" <<
#				" with existing duplicate sex and dob and mother_maiden_names" <<
#				" and #{cu} login if 'No Match'" do
#			#	waivered / nonwaivered? does it matter here?
#			subject = Factory(:complete_case_study_subject,:mother_maiden_name => 'Smith')
#			login_as send(cu)
#			minimum_waivered_successful_creation(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'No Match' )
#			assert !assigns(:duplicates)
#		end
#
##	existing mother's maiden name null
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name and #{cu} login" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					})
#			end
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login if 'Match Found' without duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found' )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login if 'Match Found' with invalid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_all_differences(0) do
#				post :create, minimum_waivered_form_attributes(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'Match Found', :duplicate_id => 0 )
#			end
#			assert_not_nil flash[:warn]
#			assert_match /No valid duplicate_id given/, flash[:warn]
#			assert_duplicates_found_and_rerendered_new
#		end
#
#		test "should NOT create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login if 'Match Found' with valid duplicate_id" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			assert_difference('OperationalEvent.count',1) {
#			assert_all_differences(0) {
#				post :create, minimum_waivered_form_attributes(
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
#		test "should create waivered case study_subject" <<
#				" with existing duplicate sex and dob and blank existing mother_maiden_name" <<
#				" and #{cu} login if 'No Match'" do
#			subject = Factory(:complete_waivered_case_study_subject)
#			login_as send(cu)
#			minimum_waivered_successful_creation(
#					'study_subject' => { 'sex' => subject.sex,
#						:dob => subject.dob, :mother_maiden_name => 'Smith'
#					}, :commit => 'No Match' )
#			assert !assigns(:duplicates)
#		end
#
##
##		END DUPLICATE CHECKING TESTS
##
#######################################################################
end
