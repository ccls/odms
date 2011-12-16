require 'integration_test_helper'

class NonwaiveredIntegrationTest < ActionController::WebRatIntegrationTest
#class NonwaiveredIntegrationTest < ActionController::CapybaraIntegrationTest

#	site_administrators.each do |cu|
	site_editors.each do |cu|

		test "should NOT create subject if duplicate subject match found with #{cu} login" do
			duplicate = Factory(:complete_nonwaivered_case_study_subject)
			login_as send(cu)
			visit new_nonwaivered_path

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
			fill_in "study_subject[pii_attributes][dob]",
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
			assert_difference('Pii.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				#	click_button(value)
				click_button "Submit"	
			} } } } } } } }

			#	is not redirected, is rendered, therefore it is just a path, not a full url
#			assert_equal nonwaivered_path, current_url
#	capybara actually has a real current_path
#			assert_equal nonwaivered_path, current_path
#	puts capybara doesn't do flash
#			assert_not_nil flash[:error]	#	Possible Duplicate(s) Found.
#			assert page.has_css?("p.flash#error")

#			assert_match /Possible Duplicate\(s\) Found/, flash[:error]

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
				#	click_button(value)
				click_button "Match Found"	
			} } } } } } } } }

#	puts capybara doesn't do flash
#			assert_not_nil flash[:notice]
#			assert page.has_css?("p.flash#error")

#			assert_match /Operational Event created marking this attempted entry/, flash[:notice]


#			assert_equal study_subject_url( duplicate ), current_url
#			assert_equal study_subject_path( duplicate ), current_path
		end

		test "should create subject if duplicate subject no match found with #{cu} login" do
			duplicate = Factory(:complete_nonwaivered_case_study_subject)
			login_as send(cu)
			visit new_nonwaivered_path

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
			fill_in "study_subject[pii_attributes][dob]",
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
			assert_difference('Pii.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				#	click_button(value)
				click_button "Submit"	
			} } } } } } } }

			#	is not redirected, is rendered, therefore it is just a path, not a full url
#			assert_equal nonwaivered_path, current_url
#	capybara actually have a current_path
#			assert_equal nonwaivered_path, current_path
#	puts capybara doesn't do flash
#			assert_not_nil flash[:error]	#	Possible Duplicate(s) Found.
#			assert page.has_css?("p.flash#error")

#			assert_match /Possible Duplicate\(s\) Found/, flash[:error]

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('Pii.count',2) {
			assert_difference('Patient.count',1) {
			assert_difference('Identifier.count',2) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				#	click_button(value)
				click_button "No Match"	
			} } } } } } } }

#			assert_equal study_subject_url( assigns(:study_subject) ), current_url
#			assert_equal study_subject_path( assigns(:study_subject) ), current_path
		end

		test "should get new nonwaivered raf form and submit with #{cu} login" do
			login_as send(cu)

			visit new_nonwaivered_path

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
			fill_in "study_subject[pii_attributes][dob]",
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
			assert_difference('Pii.count',2) {
			assert_difference('Patient.count',1) {
			assert_difference('Identifier.count',2) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				#	click_button(value)
				click_button "Submit"	
			} } } } } } } }
#	puts capybara doesn't do flash
#			assert_nil flash[:error]
#			assert !page.has_css?("p.flash#error")

#			assert_equal study_subject_url( assigns(:study_subject) ), current_url
#			assert_equal study_subject_path( assigns(:study_subject) ), current_path
		end

	end

end
