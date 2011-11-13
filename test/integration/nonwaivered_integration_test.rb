require 'integration_test_helper'

class NonwaiveredIntegrationTest < ActionController::IntegrationTest

	site_administrators.each do |cu|

		test "should get new nonwaivered raf form and submit with #{cu} login" do
			login_as send(cu)

			visit new_nonwaivered_path

			select "male", 
				:from => "study_subject[sex]"
			fill_in "study_subject[patient_attributes][hospital_no]",
				:with => "9999999999999999999999999"				#	This will NEED to be unique
			select Hospital.nonwaivered.first.organization.to_s,
				:from => "study_subject[patient_attributes][organization_id]"
			fill_in "study_subject[patient_attributes][admit_date]",
				:with => "1/31/1973"
			select "AML", 
				:from => "study_subject[patient_attributes][diagnosis_id]"
			fill_in "study_subject[pii_attributes][dob]",
				:with => "12/5/1971"

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Pii.count',2) {
			assert_difference('Patient.count',1) {
			assert_difference('Identifier.count',2) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
				#	click_button(value)
				click_button "Submit"	
			} } } } } } } }
		end

	end

end
