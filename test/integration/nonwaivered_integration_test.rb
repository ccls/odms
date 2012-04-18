require 'integration_test_helper'

class NonwaiveredIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should keep unchecked checkboxes on re-render with #{cu} login" do
			login_as send(cu)
			visit new_nonwaivered_path
			patient = 'study_subject_patient_attributes_'
			assert has_unchecked_field?("#{patient}was_under_15_at_dx")
			assert has_unchecked_field?("#{patient}was_previously_treated")
			assert has_unchecked_field?("#{patient}was_ca_resident_at_diagnosis")
			click_button "Submit"	
			wait_until { has_css?("p.flash#error") }
			assert has_unchecked_field?("#{patient}was_under_15_at_dx")
			assert has_unchecked_field?("#{patient}was_previously_treated")
			assert has_unchecked_field?("#{patient}was_ca_resident_at_diagnosis")
			check("#{patient}was_ca_resident_at_diagnosis")
			click_button "Submit"	
			wait_until { has_css?("p.flash#error") }
			assert has_unchecked_field?("#{patient}was_under_15_at_dx")
			assert has_unchecked_field?("#{patient}was_previously_treated")
			assert has_checked_field?("#{patient}was_ca_resident_at_diagnosis")
		end

		test "should NOT create subject if duplicate subject match found with #{cu} login" do
			duplicate = Factory(:complete_nonwaivered_case_study_subject)
			login_as send(cu)
			visit new_nonwaivered_path

			subject = Factory.build(:complete_nonwaivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			#	text NOT the value
			patient = "study_subject[patient_attributes]"
			select "male", 	:from => "study_subject[sex]"
			#	should trigger duplicate found
			fill_in "#{patient}[hospital_no]", :with => duplicate.hospital_no						
			select subject.organization.to_s,  :from => "#{patient}[organization_id]"
			fill_in "#{patient}[admit_date]",  :with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML",                      :from => "#{patient}[diagnosis_id]"
			fill_in "study_subject[dob]",      :with => subject.dob.strftime("%m/%d/%Y")

			address = 'study_subject[addressings_attributes][0][address_attributes]'
			fill_in "#{address}[line_1]", :with => '123 Main St'
			fill_in "#{address}[city]",   :with => 'Berkeley'
			select 'CA',                  :from => "#{address}[state]"
			fill_in "#{address}[zip]",    :with => '94703'

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				wait_until { has_css?("p.flash#error") }
			} } } } } }

			assert_equal nonwaivered_path, current_path
			assert has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/, 
				find("p.flash#error").text

			choose "duplicate_id_#{duplicate.id}"
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			assert_difference('OperationalEvent.count',1) {
				click_button "Match Found"	
				wait_until { has_css?("p.flash#notice")	}
			} } } } } } }
			assert has_css?("p.flash#notice")	#	success
			assert_match /Operational Event created marking this attempted entry/,
				find("p.flash#notice").text
			assert_equal study_subject_path( duplicate ), current_path
		end

		test "should create subject if duplicate subject no match found with #{cu} login" do
			duplicate = Factory(:complete_nonwaivered_case_study_subject)
			login_as send(cu)
			visit new_nonwaivered_path

			subject = Factory.build(:complete_nonwaivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			patient = 'study_subject[patient_attributes]'
			#	text NOT the value
			select "male", 	:from => "study_subject[sex]"
			#	should trigger duplicate found
			fill_in "#{patient}[hospital_no]", :with => duplicate.hospital_no						
			select subject.organization.to_s,  :from => "#{patient}[organization_id]"
			fill_in "#{patient}[admit_date]",  :with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML",                      :from => "#{patient}[diagnosis_id]"
			fill_in "study_subject[dob]",      :with => subject.dob.strftime("%m/%d/%Y")

			address = 'study_subject[addressings_attributes][0][address_attributes]'
			fill_in "#{address}[line_1]", :with => '123 Main St'
			fill_in "#{address}[city]",   :with => 'Berkeley'
			select 'CA',                  :from => "#{address}[state]"
			fill_in "#{address}[zip]",    :with => '94703'

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				wait_until { has_css?("p.flash#error") }
			} } } } } }
			assert_equal nonwaivered_path, current_path
			assert has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/, 
				find("p.flash#error").text

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				#	click_button(value)
				click_button "No Match"	
				#	no icf master ids warning
				wait_until { has_css?('p.flash#warn') }
			} } } } } }

			#	no icf master ids warning
			assert has_css?('p.flash#warn')
			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should get new nonwaivered raf form and submit with #{cu} login" do
			login_as send(cu)

			visit new_nonwaivered_path

			subject = Factory.build(:complete_nonwaivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			patient = 'study_subject[patient_attributes]'
			#	text NOT the value
			select "male", 	:from => "study_subject[sex]"
			fill_in "#{patient}[hospital_no]", :with => subject.hospital_no
			select subject.organization.to_s,  :from => "#{patient}[organization_id]"
			fill_in "#{patient}[admit_date]",  :with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML",                      :from => "#{patient}[diagnosis_id]"
			fill_in "study_subject[dob]",      :with => subject.dob.strftime("%m/%d/%Y")

			address = 'study_subject[addressings_attributes][0][address_attributes]'
			fill_in "#{address}[line_1]", :with => '123 Main St'
			fill_in "#{address}[city]",   :with => 'Berkeley'
			select 'CA',                  :from => "#{address}[state]"
			fill_in "#{address}[zip]",    :with => '94703'

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "Submit"	
				#	no icf master ids warning
				wait_until { has_css?('p.flash#warn') }
			} } } } } }
			#	no icf master ids warning
			assert has_css?('p.flash#warn')
			assert !has_css?("p.flash#error")
			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should maintain checked languages" <<
			" with #{cu} login" do
			login_as send(cu)
			visit new_nonwaivered_path
			assert_page_has_unchecked_language_id('english')
			check(language_input_id('english'))
			assert_page_has_checked_language_id('english')
			click_button "Submit"	
			wait_until { has_css?('p.flash#error') }
			assert_page_has_checked_language_id('english')
			uncheck(language_input_id('english'))
			assert_page_has_unchecked_language_id('english')
			click_button "Submit"	
			wait_until { has_css?('p.flash#error') }
			assert_page_has_unchecked_language_id('english')
		end

		test "should should update blank address info on zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			visit new_nonwaivered_path
			address = 'study_subject[addressings_attributes][0][address_attributes]'
			assert find_field("#{address}[city]").value.blank?
			assert find_field("#{address}[county]").value.blank?
			assert find_field("#{address}[state]").value.blank?
			assert find_field("#{address}[zip]").value.blank?

			fill_in "#{address}[zip]",  :with => "17857"

			assert_equal 'NORTHUMBERLAND', find_field("#{address}[city]").value
			assert_equal 'Northumberland', find_field("#{address}[county]").value
			assert_equal 'PA',             find_field("#{address}[state]").value
			assert_equal '17857',          find_field("#{address}[zip]").value
		end

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_nonwaivered_path
			patient = 'study_subject[patient_attributes]'
			assert !find_field( "#{patient}[other_diagnosis]").visible?
			#	case sensitive? yep.
			select "other", :from => "#{patient}[diagnosis_id]"
			assert find_field( "#{patient}[other_diagnosis]").visible?
			select "",      :from => "#{patient}[diagnosis_id]"
			assert !find_field( "#{patient}[other_diagnosis]").visible?
			select "other", :from => "#{patient}[diagnosis_id]"
			assert find_field( "#{patient}[other_diagnosis]").visible?
		end

	end

end
