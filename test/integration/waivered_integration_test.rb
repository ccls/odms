require 'integration_test_helper'

class WaiveredIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other_language]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other_language]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_editors.each do |cu|

		test "should NOT create subject if duplicate subject match found with #{cu} login" do
			duplicate = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			visit new_waivered_path

			subject = Factory.build(:complete_waivered_case_study_subject)	
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

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				wait_until { has_css?("p.flash#error") }
			} } } } } }

			assert_equal waivered_path, current_path
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
				wait_until { has_css?("p.flash#notice") }
			} } } } } } }
			assert has_css?("p.flash#notice")
			assert_match /Operational Event created marking this attempted entry/,
				find("p.flash#notice").text
			assert_equal study_subject_path( duplicate ), current_path
		end

		test "should create subject if duplicate subject no match found with #{cu} login" do
			duplicate = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			visit new_waivered_path

			subject = Factory.build(:complete_waivered_case_study_subject)	
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

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
				click_button "Submit"	
				wait_until { has_css?("p.flash#error") }
			} } } } } }

			assert_equal waivered_path, current_path
			assert has_css?("p.flash#error")
			assert_match /Possible Duplicate\(s\) Found/,
				find("p.flash#error").text

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "No Match"	
				#	no icf master ids warning
				wait_until { has_css?('p.flash#warn') }
			} } } } } }

			#	no icf master ids warning
			assert has_css?('p.flash#warn')
			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should get new waivered raf form and submit with #{cu} login" do
			login_as send(cu)

			visit new_waivered_path

			subject = Factory.build(:complete_waivered_case_study_subject)	
			#	build, but DON'T save
			#	by using the attributes from this built subject, 
			#	we test the factory and use its sequencing

			#	select(option_text, options = {})	
			#	selects on the inner content of the option tag, NOT the option tag's value.
			#	it would be very nice to be able to select something without knowing (ie select first)
			patient = 'study_subject[patient_attributes]'
			select "male", :from => "study_subject[sex]"
			fill_in "#{patient}[hospital_no]", :with => subject.hospital_no
			select subject.organization.to_s,  :from => "#{patient}[organization_id]"
			fill_in "#{patient}[admit_date]",  :with => subject.admit_date.strftime("%m/%d/%Y")
			select "AML",                      :from => "#{patient}[diagnosis_id]"
			fill_in "study_subject[dob]",      :with => subject.dob.strftime("%m/%d/%Y")

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "Submit"	
				#	no icf master ids
				wait_until { has_css?('p.flash#warn') }
			} } } } } }
			#	no icf master ids
			assert has_css?('p.flash#warn')
			assert !has_css?("p.flash#error")
			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should maintain checked languages" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_waivered_path
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

		test "should toggle specify other language when other language checked" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_waivered_path
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
			visit new_waivered_path
			address = "study_subject[addressings_attributes][0][address_attributes]"
			patient = 'study_subject[patient_attributes]'
			assert find_field("#{address}[city]").value.blank?
			assert find_field("#{address}[county]").value.blank?
			assert find_field("#{address}[state]").value.blank?
			assert find_field("#{address}[zip]").value.blank?
			assert find_field("#{patient}[raf_county]").value.blank?
			assert find_field("#{patient}[raf_zip]").value.blank?

			fill_in "#{address}[zip]", :with => "17857"

			assert_equal 'NORTHUMBERLAND', find_field("#{address}[city]").value
			assert_equal 'Northumberland', find_field("#{address}[county]").value
			assert_equal 'PA',             find_field("#{address}[state]").value
			assert_equal '17857',          find_field("#{address}[zip]").value
			assert_equal 'Northumberland', find_field("#{patient}[raf_county]").value
			assert_equal '17857',          find_field("#{patient}[raf_zip]").value
		end

		test "should should update blank address info on raf_zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			visit new_waivered_path
			address = "study_subject[addressings_attributes][0][address_attributes]"
			patient = 'study_subject[patient_attributes]'
			assert find_field("#{address}[city]").value.blank?
			assert find_field("#{address}[county]").value.blank?
			assert find_field("#{address}[state]").value.blank?
			assert find_field("#{address}[zip]").value.blank?
			assert find_field("#{patient}[raf_county]").value.blank?
			assert find_field("#{patient}[raf_zip]").value.blank?

			fill_in "#{patient}[raf_zip]",  :with => "17857"

			assert_equal 'NORTHUMBERLAND', find_field("#{address}[city]").value
			assert_equal 'Northumberland', find_field("#{address}[county]").value
			assert_equal 'PA',             find_field("#{address}[state]").value
			assert_equal '17857',          find_field("#{address}[zip]").value
			assert_equal 'Northumberland', find_field("#{patient}[raf_county]").value
			assert_equal '17857',          find_field("#{patient}[raf_zip]").value
		end

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_waivered_path
			patient = 'study_subject[patient_attributes]'
			assert !find_field("#{patient}[other_diagnosis]").visible?
			select "other", :from => "#{patient}[diagnosis_id]"
			assert find_field("#{patient}[other_diagnosis]").visible?
			select "",      :from => "#{patient}[diagnosis_id]"
			assert !find_field("#{patient}[other_diagnosis]").visible?
			select "other", :from => "#{patient}[diagnosis_id]"
			assert find_field("#{patient}[other_diagnosis]").visible?
		end

		test "should show other_refusal_reason when refusal_reason is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_waivered_path
			patient = "study_subject[enrollments_attributes][0]"
			assert !find_field("#{patient}[other_refusal_reason]").visible?
			select "other reason for refusal", :from => "#{patient}[refusal_reason_id]"
			assert find_field("#{patient}[other_refusal_reason]").visible?
			select "",                         :from => "#{patient}[refusal_reason_id]"
			assert !find_field("#{patient}[other_refusal_reason]").visible?
			select "other reason for refusal", :from => "#{patient}[refusal_reason_id]"
			assert find_field("#{patient}[other_refusal_reason]").visible?
		end

	end

end
