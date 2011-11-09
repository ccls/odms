require 'integration_test_helper'

class WaiveredIntegrationTest < ActionController::IntegrationTest

	site_administrators.each do |cu|

		test "should get new waivered raf form and submit with #{cu} login" do
			login_as send(cu)

			#	need to set HTTPS for webrat
			header('HTTPS', 'on')
			visit new_waivered_path

			#	select(option_text, options = {})	
			#	selects on the inner content of the option tag, NOT the option tag's value.
			#	it would be very nice to be able to select something without knowing (ie select first)
			select "male", 
				:from => "study_subject[sex]"
			fill_in "study_subject[patient_attributes][hospital_no]",
				:with => "9999999999999999999999999"				#	This will NEED to be unique
#			select "California Pacific Medical Center",		#	I don't know if this is a WAIVERED hospital or not
			select Hospital.waivered.first.organization.to_s,
				:from => "study_subject[patient_attributes][organization_id]"
			fill_in "study_subject[patient_attributes][admit_date]",
				:with => "1/31/1973"
			select "AML", 
				:from => "study_subject[patient_attributes][diagnosis_id]"
			fill_in "study_subject[pii_attributes][dob]",
				:with => "12/5/1971"

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Addressing.count',0) {
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
