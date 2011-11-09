require 'integration_test_helper'

class CaseIntegrationTest < ActionController::IntegrationTest

	site_administrators.each do |cu|

		test "should preselect waivered organization_id from new case with #{cu} login" do
			login_as send(cu)
			visit new_case_path
			assert_equal new_case_path, current_url
			hospital = Hospital.waivered.first
			select hospital.organization.to_s, :from => "hospital_id"
			click_button "New Case"	

#https://www.example.com/waivered/new?study_subject%5Bpatient_attributes%5D%5Borganization_id%5D=1
			assert_match /https:\/\/.*\/waivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url

			assert_select "input" <<
				"#study_subject_patient_attributes_organization_id" <<
				"[name='study_subject[patient_attributes][organization_id]']" <<
				"[value=#{hospital.organization_id}]" <<
				"[type='hidden']", 1
		end

		test "should preselect nonwaivered organization_id from new case with #{cu} login" do
			login_as send(cu)
			visit new_case_path
			assert_equal new_case_path, current_url
			hospital = Hospital.nonwaivered.first
			select hospital.organization.to_s, :from => "hospital_id"
			click_button "New Case"	

#https://www.example.com/nonwaivered/new?study_subject%5Bpatient_attributes%5D%5Borganization_id%5D=3
			assert_match /https:\/\/.*\/nonwaivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url

			assert_select "input" <<
				"#study_subject_patient_attributes_organization_id" <<
				"[name='study_subject[patient_attributes][organization_id]']" <<
				"[value=#{hospital.organization_id}]" <<
				"[type='hidden']", 1
		end

	end

end
