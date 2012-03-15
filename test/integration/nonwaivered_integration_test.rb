require 'integration_test_helper'

class NonwaiveredIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other_language]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other_language]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_editors.each do |cu|

		test "should keep unchecked checkboxes on re-render with #{cu} login" do
#	TODO noticed that validation failure and re-render, checks these boxes???
#	manually setting the checked attribute fixes, but don't understand why
			login_as send(cu)
			page.visit new_nonwaivered_path

			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_under_15_at_dx')
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_previously_treated')
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_ca_resident_at_diagnosis')
			click_button "Submit"	
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_under_15_at_dx')
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_previously_treated')
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_ca_resident_at_diagnosis')

			check('study_subject_patient_attributes_was_ca_resident_at_diagnosis')
			click_button "Submit"	
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_under_15_at_dx')
			assert page.has_unchecked_field?(
				'study_subject_patient_attributes_was_previously_treated')
			assert page.has_checked_field?(
				'study_subject_patient_attributes_was_ca_resident_at_diagnosis')
		end

		test "should NOT create subject if duplicate subject match found with #{cu} login" do
			duplicate = Factory(:complete_nonwaivered_case_study_subject)
			login_as send(cu)
			page.visit new_nonwaivered_path

			subject = Factory.build(:complete_nonwaivered_case_study_subject)	
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
			fill_in "study_subject[dob]",
				:with => subject.dob.strftime("%m/%d/%Y")

			fill_in 'study_subject[addressings_attributes][0][address_attributes][line_1]',
				:with => '123 Main St'
			fill_in 'study_subject[addressings_attributes][0][address_attributes][city]',
				:with => 'Berkeley'
			select 'CA',
				:from => 'study_subject[addressings_attributes][0][address_attributes][state]'
			fill_in 'study_subject[addressings_attributes][0][address_attributes][zip]',
				:with => '94703'

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				sleep 2	#	pause to ensure no changes in capybara
			} } } } } }

			assert_equal nonwaivered_path, current_path
			assert page.has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/, 
				page.find("p.flash#error").text

			choose "duplicate_id_#{duplicate.id}"
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			assert_difference('OperationalEvent.count',1) {
				click_button "Match Found"	
				sleep 2	#	capybara will require a moment to get the counts correct
			} } } } } } }
			assert page.has_css?("p.flash#notice")	#	success
			assert_match /Operational Event created marking this attempted entry/,
				page.find("p.flash#notice").text
			assert_equal study_subject_path( duplicate ), current_path
		end

		test "should create subject if duplicate subject no match found with #{cu} login" do
			duplicate = Factory(:complete_nonwaivered_case_study_subject)
			login_as send(cu)
			page.visit new_nonwaivered_path

			subject = Factory.build(:complete_nonwaivered_case_study_subject)	
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
			fill_in "study_subject[dob]",
				:with => subject.dob.strftime("%m/%d/%Y")

			fill_in 'study_subject[addressings_attributes][0][address_attributes][line_1]',
				:with => '123 Main St'
			fill_in 'study_subject[addressings_attributes][0][address_attributes][city]',
				:with => 'Berkeley'
			select 'CA',
				:from => 'study_subject[addressings_attributes][0][address_attributes][state]'
			fill_in 'study_subject[addressings_attributes][0][address_attributes][zip]',
				:with => '94703'

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				sleep 2	#	pause to ensure no changes in capybara
			} } } } } }
			assert_equal nonwaivered_path, current_path
			assert page.has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/, 
				page.find("p.flash#error").text

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				#	click_button(value)
				click_button "No Match"	
				sleep 2	#	capybara will require a moment to get the counts correct
			} } } } } }

			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should get new nonwaivered raf form and submit with #{cu} login" do
			login_as send(cu)

			page.visit new_nonwaivered_path

			subject = Factory.build(:complete_nonwaivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			select "male", 	#	text NOT the value
				:from => "study_subject[sex]"
			fill_in "study_subject[patient_attributes][hospital_no]",
				:with => subject.hospital_no
			select subject.organization.to_s,
				:from => "study_subject[patient_attributes][organization_id]"
			fill_in "study_subject[patient_attributes][admit_date]",
				:with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML", 
				:from => "study_subject[patient_attributes][diagnosis_id]"
			fill_in "study_subject[dob]",
				:with => subject.dob.strftime("%m/%d/%Y")

			fill_in 'study_subject[addressings_attributes][0][address_attributes][line_1]',
				:with => '123 Main St'
			fill_in 'study_subject[addressings_attributes][0][address_attributes][city]',
				:with => 'Berkeley'
			select 'CA',
				:from => 'study_subject[addressings_attributes][0][address_attributes][state]'
			fill_in 'study_subject[addressings_attributes][0][address_attributes][zip]',
				:with => '94703'

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "Submit"	
				sleep 3	#	capybara will require a moment to get the counts correct
			} } } } } }
			assert !page.has_css?("p.flash#error")
			assert_match /\/study_subjects\/\d+/, current_path
		end


#	TODO add tests which test the subject languages checkboxes on kickbacks

#	No 'other' language on nonwaivered form


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

			fill_in "study_subject[addressings_attributes][0][address_attributes][zip]",  
				:with => "17857"
			#	I don't think that the change event get triggered correctly
			#	in the test environment.
			#
			#	This may happen as the browser
			#	actually exists and perhaps me coding while the browser is trying to
			#	test takes focus away from it?  Can I force the browser into the background?
			#
			#	maybe "change" isn't the appropriate event trigger for this?
			#	explicitly trigger the change event.
			#	If the user running the tests is using the machine,
			#	it can inhibit this test.  Don't know why.
			#	It will send a blank zip code which will result in
			#	no field updates.
#	When using capybara-webkit, this isn't necessary!  Yay!
#		If we change back to selenium, this may need uncommented.
#			page.execute_script("$('#study_subject_addressings_attributes_0_address_attributes_zip').change()" );
#			sleep 1

			assert_equal 'NORTHUMBERLAND', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][city]").value
			assert_equal 'Northumberland', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][county]").value
			assert_equal 'PA', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][state]").value
			assert_equal '17857', page.find_field(
				"study_subject[addressings_attributes][0][address_attributes][zip]").value
		end

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			page.visit new_waivered_path
			assert !page.find_field( 'study_subject[patient_attributes][other_diagnosis]').visible?
#	case sensitive? yep.
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.find_field( 'study_subject[patient_attributes][other_diagnosis]').visible?
			select "", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert !page.find_field( 'study_subject[patient_attributes][other_diagnosis]').visible?
			select "other", :from => 'study_subject[patient_attributes][diagnosis_id]'
			assert page.find_field( 'study_subject[patient_attributes][other_diagnosis]').visible?
		end

	end

end
