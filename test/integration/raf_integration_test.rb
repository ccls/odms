require 'integration_test_helper'

class RafIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should NOT create subject if duplicate subject match found with #{cu} login" do
			duplicate = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			visit new_raf_path

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
				click_button "New Case"	
				wait_until { has_css?("p.flash.error") }
			} } } } } }

			assert_equal rafs_path, current_path
			assert has_css?("p.flash.error")
			assert_match /Possible Duplicate\(s\) Found/,
				find("p.flash.error").text

			choose "duplicate_id_#{duplicate.id}"
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			assert_difference('OperationalEvent.count',1) {
				click_button "Match Found"	
				wait_until { has_css?("p.flash.notice") }
			} } } } } } }
			assert has_css?("p.flash.notice")
			assert_match /Operational Event created marking this attempted entry/,
				find("p.flash.notice").text
			assert_equal study_subject_path( duplicate ), current_path
		end

		test "should create subject if duplicate subject no match found with #{cu} login" do
			duplicate = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			visit new_raf_path

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
				click_button "New Case"	
				wait_until { has_css?("p.flash.error") }
			} } } } } }

			assert_equal rafs_path, current_path
			assert has_css?("p.flash.error")
			assert_match /Possible Duplicate\(s\) Found/,
				find("p.flash.error").text

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',1) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				click_button "No Match"	
				#	no icf master ids warning
				wait_until { has_css?('p.flash.warn') }
			} } } } } }

			#	no icf master ids warning
			assert has_css?('p.flash.warn')
			assert_match /\/study_subjects\/\d+/, current_path
		end

		test "should get new waivered raf form and submit with #{cu} login" do
			login_as send(cu)

			visit new_raf_path

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
				click_button "New Case"	
				#	no icf master ids
				wait_until { has_css?('p.flash.warn') }
			} } } } } }
			#	no icf master ids
			assert has_css?('p.flash.warn')
			assert !has_css?("p.flash.error")



			assert_match /\/study_subjects\/\d+/, current_path



		end

		test "should maintain checked languages" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_raf_path
			assert_page_has_unchecked_language_id('english')
			check(language_input_id('english'))
			assert_page_has_checked_language_id('english')
			click_button "New Case" 
			wait_until { has_css?('p.flash.error') }
			assert_page_has_checked_language_id('english')
			uncheck(language_input_id('english'))
			assert_page_has_unchecked_language_id('english')
			click_button "New Case" 
			wait_until { has_css?('p.flash.error') }
			assert_page_has_unchecked_language_id('english')
		end

		test "should toggle specify other language when other language checked" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_raf_path
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
			check(language_input_id('other'))
			assert_page_has_checked_language_id('other')
			assert_other_language_visible
			uncheck(language_input_id('other'))
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
		end

		test "should update blank address info on zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			visit new_raf_path
			address = "study_subject[addressings_attributes][0][address_attributes]"
			patient = 'study_subject[patient_attributes]'
			assert find_field("#{address}[city]").value.blank?
			assert find_field("#{address}[county]").value.blank?
			assert find_field("#{address}[state]").value.blank?
			assert find_field("#{address}[zip]").value.blank?
			assert find_field("#{patient}[raf_county]").value.blank?
			assert find_field("#{patient}[raf_zip]").value.blank?

			fill_in "#{address}[zip]", :with => "17857"

			assert_equal 'Northumberland', find_field("#{address}[city]").value
			assert_equal 'Northumberland', find_field("#{address}[county]").value
			assert_equal 'PA',             find_field("#{address}[state]").value
			assert_equal '17857',          find_field("#{address}[zip]").value
			assert_equal 'Northumberland', find_field("#{patient}[raf_county]").value
			assert_equal '17857',          find_field("#{patient}[raf_zip]").value
		end

		test "should update blank address info on raf_zip code change" <<
			" with #{cu} login" do
			login_as send(cu)
			visit new_raf_path
			address = "study_subject[addressings_attributes][0][address_attributes]"
			patient = 'study_subject[patient_attributes]'
			assert find_field("#{address}[city]").value.blank?
			assert find_field("#{address}[county]").value.blank?
			assert find_field("#{address}[state]").value.blank?
			assert find_field("#{address}[zip]").value.blank?
			assert find_field("#{patient}[raf_county]").value.blank?
			assert find_field("#{patient}[raf_zip]").value.blank?

			fill_in "#{patient}[raf_zip]",  :with => "17857"

			wait_until{ 
				!find_field("#{address}[city]").value.blank? }

			assert_equal 'Northumberland', find_field("#{address}[city]").value
			assert_equal 'Northumberland', find_field("#{address}[county]").value
			assert_equal 'PA',             find_field("#{address}[state]").value
			assert_equal '17857',          find_field("#{address}[zip]").value
			assert_equal 'Northumberland', find_field("#{patient}[raf_county]").value
			assert_equal '17857',          find_field("#{patient}[raf_zip]").value
		end

		test "should show other_diagnosis when diagnosis is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_raf_path
			patient = 'study_subject[patient_attributes]'
			assert !find_field("#{patient}[other_diagnosis]").visible?
			select "other diagnosis", :from => "#{patient}[diagnosis_id]"
			assert find_field("#{patient}[other_diagnosis]").visible?
			select "",      :from => "#{patient}[diagnosis_id]"
			assert !find_field("#{patient}[other_diagnosis]").visible?
			select "other diagnosis", :from => "#{patient}[diagnosis_id]"
			assert find_field("#{patient}[other_diagnosis]").visible?
		end

		test "should show other_refusal_reason when refusal_reason is Other" <<
				" with #{cu} login" do
			login_as send(cu)
			visit new_raf_path
			patient = "study_subject[enrollments_attributes][0]"
			assert !find_field("#{patient}[other_refusal_reason]").visible?
			select "other reason for refusal", :from => "#{patient}[refusal_reason_id]"
			assert find_field("#{patient}[other_refusal_reason]").visible?
			select "",                         :from => "#{patient}[refusal_reason_id]"
			assert !find_field("#{patient}[other_refusal_reason]").visible?
			select "other reason for refusal", :from => "#{patient}[refusal_reason_id]"
			assert find_field("#{patient}[other_refusal_reason]").visible?
		end



		test "test edit complete case with #{cu} login" do
			subject = Factory(:complete_waivered_case_study_subject)
			login_as send(cu)
			visit edit_raf_path(:id => subject.id)
#	TODO should add some stuff here
		end



	end

#end
#
#	site_editors.each do |cu|
#
#		test "should preselect waivered organization_id from new case with #{cu} login" do
#			login_as send(cu)
#			visit new_raf_path
#			assert_equal new_raf_path, current_path
#
#			hospital = Hospital.active.waivered.first
#
#			select hospital.organization.to_s, :from => "hospital_id"
#			click_button "New Case"	
#
##	current_url is not following redirect
##	This used to work in rails 2 and does work in the functional tests.
##	TODO the page content appears correct, but the url is rafs_path
##			assert_match /http(s)?:\/\/.*\/waivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url
#
#			#	This isn't perfect, but it does test that the redirect is correct.
#			#	If I can't test that I've been redirected, test the page content.
#			assert_select HTML::Document.new(body).root, 'div#main h3', 
#				:text => "Rapid Ascertainment Form (RAF) - waiver version"
#
#			#	capybara apparently won't find a field by name that is
#			#		type=hidden, however, finding it by css works.
#			assert_equal hospital.organization_id.to_s,
#				find('#study_subject_patient_attributes_organization_id').value
#		end
#
#		test "should preselect nonwaivered organization_id from new case with #{cu} login" do
#			login_as send(cu)
#			visit new_raf_path
#			assert_equal new_raf_path, current_path
#
#			hospital = Hospital.active.nonwaivered.first
#			select hospital.organization.to_s, :from => "hospital_id"
#			click_button "New Case"	
#
##	current_url is not following redirect
##	This used to work in rails 2 and does work in the functional tests.
##	TODO the page content appears correct, but the url is rafs_path
##			assert_match /http(s)?:\/\/.*\/nonwaivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url
#
#			#	This isn't perfect, but it does test that the redirect is correct.
#			#	If I can't test that I've been redirected, test the page content.
#			assert_select HTML::Document.new(body).root, 'div#main h3', 
#				:text => "Rapid Ascertainment Form (RAF) - non-waiver version"
#
#			#	capybara apparently won't find a field by name that is
#			#		type=hidden, however, finding it by css works.
#			assert_equal hospital.organization_id.to_s,
#				find('#study_subject_patient_attributes_organization_id').value
#		end
#
#	end

end
__END__
I'm still not clear on whether I need to use "page." or not.
It seems like page == self and is therefore unnecessary.

page.visit =? visit
page.find =? find
page.click =? click
page.body =? body
page.select =? select

current_path and current_url still don't update on a redirect






__END__
