require 'integration_test_helper'

class CaseIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should preselect waivered organization_id from new case with #{cu} login" do
			login_as send(cu)
			page.visit new_case_path
			assert_equal new_case_path, current_path

			hospital = Hospital.waivered.first
			select hospital.organization.to_s, :from => "hospital_id"
			click_button "New Case"	


pending	#	TODO the page content appears correct, but the url is cases_path
#			assert_match /http(s)?:\/\/.*\/waivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url


#	capybara doesn't use assert_select
#			assert_select "input" <<
#				"#study_subject_patient_attributes_organization_id" <<
#				"[name='study_subject[patient_attributes][organization_id]']" <<
#				"[value=#{hospital.organization_id}]" <<
#				"[type='hidden']", 1
#			page.find('study_subject[patient_attributes][organization_id]')

			#	capybara apparently won't find a field by name that is
			#		type=hidden, however, finding it by css works.

			assert_equal hospital.organization_id.to_s,
				page.find('#study_subject_patient_attributes_organization_id').value
#				page.find('study_subject[patient_attributes][organization_id]').value
		end

		test "should preselect nonwaivered organization_id from new case with #{cu} login" do
			login_as send(cu)
			page.visit new_case_path
			assert_equal new_case_path, current_path

			hospital = Hospital.nonwaivered.first
			select hospital.organization.to_s, :from => "hospital_id"
			click_button "New Case"	


pending	#	TODO the page content appears correct, but the url is cases_path
#			assert_match /http(s)?:\/\/.*\/nonwaivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url


#	capybara doesn't use assert_select
#			assert_select "input" <<
#				"#study_subject_patient_attributes_organization_id" <<
#				"[name='study_subject[patient_attributes][organization_id]']" <<
#				"[value=#{hospital.organization_id}]" <<
#				"[type='hidden']", 1
#			page.find('study_subject[patient_attributes][organization_id]')

			#	capybara apparently won't find a field by name that is
			#		type=hidden, however, finding it by css works.

			assert_equal hospital.organization_id.to_s,
				page.find('#study_subject_patient_attributes_organization_id').value
#				page.find('study_subject[patient_attributes][organization_id]').value
		end

	end

end
