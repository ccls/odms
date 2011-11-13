require 'integration_test_helper'

class NonwaiveredIntegrationTest < ActionController::IntegrationTest

	site_administrators.each do |cu|

		test "should add a couple duplicate subject tests here with #{cu} login" do
pending	#	TODO	complete_nonwaivered_case_study_subject
#puts Factory.attributes_for(:complete_case_study_subject).inspect
#{:pii_attributes=>{:dob=>Tue, 30 Dec 2003, :email=>"email2@example.com"}, :patient_attributes=>{:admit_date=>Sun, 13 Nov 2011, :hospital_no=>"2", :organization_id=>1, :diagnosis_id=>1}, :subject_type=>#<SubjectType id: 1, position: nil, code: "Case", description: "Case", related_case_control_type: nil, created_at: "2011-11-13 20:43:35", updated_at: "2011-11-13 20:43:35">, :sex=>"M", :identifier_attributes=>{:state_registrar_no=>"2", :local_registrar_no=>"2", :icf_master_id=>"2", :gbid=>"2", :accession_no=>"2", :ssn=>"000000002", :lab_no_wiemels=>"2", :state_id_no=>"2", :idno_wiemels=>"2", :case_control_type=>"c"}}
		end

		test "should get new nonwaivered raf form and submit with #{cu} login" do
			login_as send(cu)

			visit new_nonwaivered_path

#	attributes = Factory.attributes_for(:complete_nonwaivered_case_study_subject)
#	then try to use these attributes in form?

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
