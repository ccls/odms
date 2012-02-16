require 'integration_test_helper'

class WaiveredIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_editors.each do |cu|

		test "should NOT create subject if duplicate subject match found with #{cu} login" do
			duplicate = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			page.visit new_waivered_path

			subject = Factory.build(:complete_waivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			select "male", 	#	text NOT the value
				:from => "study_subject[sex]"
			fill_in "study_subject[patient_attributes][hospital_no]",
				:with => duplicate.hospital_no						#	should trigger duplicate found
			select subject.organization.to_s,
				:from => "study_subject[patient_attributes][organization_id]"
			fill_in "study_subject[patient_attributes][admit_date]",
				:with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML", 
				:from => "study_subject[patient_attributes][diagnosis_id]"
			fill_in "study_subject[pii_attributes][dob]",
				:with => subject.dob.strftime("%m/%d/%Y")

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Pii.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				sleep 2	#	for capybara
			} } } } } } } }

			assert_equal waivered_path, current_path
			assert page.has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/,
				page.find("p.flash#error").text

			choose "duplicate_id_#{duplicate.id}"
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Pii.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			assert_difference('OperationalEvent.count',1) {
				click_button "Match Found"	
				sleep 2	#	for capybara
			} } } } } } } } }
			assert page.has_css?("p.flash#notice")
			assert_match /Operational Event created marking this attempted entry/,
				page.find("p.flash#notice").text
			assert_equal study_subject_path( duplicate ), current_path
		end

		test "should create subject if duplicate subject no match found with #{cu} login" do
			duplicate = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			page.visit new_waivered_path

			subject = Factory.build(:complete_waivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			select "male", 	#	text NOT the value
				:from => "study_subject[sex]"
			fill_in "study_subject[patient_attributes][hospital_no]",
				:with => duplicate.hospital_no						#	should trigger duplicate found
			select subject.organization.to_s,
				:from => "study_subject[patient_attributes][organization_id]"
			fill_in "study_subject[patient_attributes][admit_date]",
				:with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML", 
				:from => "study_subject[patient_attributes][diagnosis_id]"
			fill_in "study_subject[pii_attributes][dob]",
				:with => subject.dob.strftime("%m/%d/%Y")

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Pii.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				sleep 2	#	for capybara
			} } } } } } } }

			assert_equal waivered_path, current_path
			assert page.has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/,
				page.find("p.flash#error").text

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Pii.count',2) {
			assert_difference('Patient.count',1) {
			assert_difference('Identifier.count',2) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "No Match"	
				sleep 2	#	for capybara
			} } } } } } } }

			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should get new waivered raf form and submit with #{cu} login" do
			login_as send(cu)

			page.visit new_waivered_path

			subject = Factory.build(:complete_waivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			#	select(option_text, options = {})	
			#	selects on the inner content of the option tag, NOT the option tag's value.
			#	it would be very nice to be able to select something without knowing (ie select first)
			select "male", 
				:from => "study_subject[sex]"
			fill_in "study_subject[patient_attributes][hospital_no]",
				:with => subject.hospital_no
			select subject.organization.to_s,
				:from => "study_subject[patient_attributes][organization_id]"
			fill_in "study_subject[patient_attributes][admit_date]",
				:with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML", 
				:from => "study_subject[patient_attributes][diagnosis_id]"
			fill_in "study_subject[pii_attributes][dob]",
				:with => subject.dob.strftime("%m/%d/%Y")

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Pii.count',2) {
			assert_difference('Patient.count',1) {
			assert_difference('Identifier.count',2) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "Submit"	
				sleep 2	#	for capybara
			} } } } } } } }
			assert !page.has_css?("p.flash#error")
			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should toggle specify other language when other language checked" <<
				" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
			check(language_input_id('other'))
			assert_page_has_checked_language_id('other')
			assert_other_language_visible
			uncheck(language_input_id('other'))
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
		end

		test "should should update blank address info on zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_county]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_zip]").value.blank?

			fill_in "study_subject[addressings_attributes][0][address_attributes][zip]",  
				:with => "17857"

			assert_equal 'NORTHUMBERLAND', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value
			assert_equal 'PA', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value
			assert_equal '17857', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[patient_attributes][raf_county]").value
			assert_equal '17857', page.find_field(
				"study_subject[patient_attributes][raf_zip]").value
		end

		test "should should update blank address info on raf_zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value.blank?
			assert page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_county]").value.blank?
			assert page.find_field(
				"study_subject[patient_attributes][raf_zip]").value.blank?

			fill_in "study_subject[patient_attributes][raf_zip]",  :with => "17857"

			assert_equal 'NORTHUMBERLAND', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value
			assert_equal 'PA', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value
			assert_equal '17857', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[patient_attributes][raf_county]").value
			assert_equal '17857', page.find_field(
				"study_subject[patient_attributes][raf_zip]").value
		end

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert !page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
#	case sensitive? yep.
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
			select "", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert !page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.find_field('study_subject[patient_attributes][other_diagnosis]').visible?
		end

	end

end
