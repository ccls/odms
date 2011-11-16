require 'integration_test_helper'

class CandidateControlIntegrationTest < ActionController::IntegrationTest

	site_administrators.each do |cu|

		test "should create control for case with no duplicates and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(
				:related_patid => case_study_subject.reload.patid,
					:updated_at => Date.yesterday )

			visit case_path(case_study_subject.id)
			click_link 'add control'
			#	Only one control so should go to it.
			assert_equal current_url, edit_candidate_control_url(candidate)

			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Pii.count',2) {
			assert_difference('Identifier.count',2) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
			} } } } } } } } }

#	will exist but should test whether empty or not.
#			assert !assigns(:duplicates)

			candidate.reload
			assert        !candidate.reject_candidate
			assert         candidate.rejection_reason.blank?
			assert_not_nil candidate.assigned_on
			assert_not_nil candidate.study_subject
			assert_not_nil candidate.study_subject.mother

			assert_nil flash[:error]
			assert_equal current_url, case_url(case_study_subject.id)
		end

		test "should NOT create control subject if duplicate subject" <<
				" with #{cu} login and 'Match Found' and no duplicate_id" do
		end

		test "should NOT create control subject if duplicate subject" <<
				" with #{cu} login and 'Match Found'" do
		end

		test "should create control subject if duplicate subject" <<
				" with #{cu} login and 'No Match' found" do
		end

	end

end
