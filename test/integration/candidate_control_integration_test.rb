require 'integration_test_helper'

class CandidateControlIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should create control for case with no duplicates and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			candidate = Factory(:candidate_control,
				:related_patid => case_study_subject.reload.patid,
					:updated_at => ( Date.today - 2.days ) )

			page.visit related_subject_path(case_study_subject.id)
			assert_equal current_path, related_subject_path(case_study_subject.id)
			click_link 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !page.has_css?('div.possible_duplicates')

			#	realistically, must 'choose' a radio button by id as the name is not likely unique
			#	as most radio buttons are part of a 'group' and the group is defined by a shared name value.
			#	Apparently, we can also choose by the label text, but haven't tried this.
#<p><input id="candidate_control_reject_candidate_false" name="candidate_control[reject_candidate]" type="radio" value="false" />
#<label for="candidate_control_reject_candidate_false">accept control</label></p>
#<p><input checked="checked" id="candidate_control_reject_candidate_true" name="candidate_control[reject_candidate]" type="radio" value="true" />
#<label for="candidate_control_reject_candidate_true">reject control</label></p>
			#choose 'candidate_control[reject_candidate][value=false]'
			#choose 'candidate_control[reject_candidate]'	#	works, but how?  chooses the first one?
			choose 'candidate_control_reject_candidate_false'
#<textarea cols="40" id="candidate_control_rejection_reason" name="candidate_control[rejection_reason]" rows="10">DOB does not match.
			# fill_in 'candidate_control_rejection_reason', :with => ''
			fill_in 'candidate_control[rejection_reason]', :with => ''

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
				sleep 2	#	If I don't sleep in capybara, the counts don't change???
			} } } } } } }

			assert_candidate_assigned_and_accepted(candidate.reload)
			assert !page.has_css?("p.flash#error")
			assert_equal current_path, related_subject_path(case_study_subject.id)
		end

		test "should NOT create control subject if duplicate subject" <<
				" with #{cu} login and 'Match Found' and no duplicate_id" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			candidate = Factory(:candidate_control,
				:related_patid => case_study_subject.reload.patid,
					:updated_at => ( Date.today - 2.days ) )
			duplicate = Factory(:study_subject,
				:sex => candidate.sex,
				:dob => candidate.dob,
				:mother_maiden_name => candidate.mother_maiden_name)
			page.visit related_subject_path(case_study_subject.id)
			assert_equal current_path, related_subject_path(case_study_subject.id)
			click_link 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !page.has_css?('div.possible_duplicates')
			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
			} } } } } } }

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????
			assert page.has_css?("p.flash#error")
			assert_equal current_path, candidate_control_path(candidate)
			assert page.has_css?('div.possible_duplicates')

			#	don't choose a duplicate
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'Match Found'
			} } } } } } }
			assert page.has_css?('div.possible_duplicates')
			assert page.has_css?("p.flash#error")
			assert page.has_css?("p.flash#warn")

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????
			assert_equal current_path, candidate_control_path(candidate)
		end

		test "should NOT create control subject if duplicate subject" <<
				" with #{cu} login and 'Match Found' and valid duplicate_id" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			candidate = Factory(:candidate_control,
				:related_patid => case_study_subject.reload.patid,
					:updated_at => ( Date.today - 2.days ) )
			duplicate = Factory(:study_subject,
				:sex => candidate.sex,
				:dob => candidate.dob,
				:mother_maiden_name => candidate.mother_maiden_name)
			page.visit related_subject_path(case_study_subject.id)
			click_link 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !page.has_css?('div.possible_duplicates')
			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
			} } } } } } }

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????
			assert page.has_css?("p.flash#error")
			assert_equal current_path, candidate_control_path(candidate)
			assert page.has_css?('div.possible_duplicates')

			#	choose a duplicate
			choose "duplicate_id_#{duplicate.id}"
			#	no new records, just a modified candidate_control record
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'Match Found'
				sleep 1	#	If I don't sleep in capybara, the counts don't change???
			} } } } } } }

			assert_candidate_rejected(candidate.reload)
			# as the created duplicate is not explicitly a case
			# the reason will be because it is a control
			assert_match /ineligible control - control already exists in system/,
				candidate.rejection_reason
			assert !page.has_css?("p.flash#error")
			assert_equal current_path, related_subject_path(case_study_subject.id)
		end

		test "should create control subject if duplicate subject" <<
				" with #{cu} login and 'No Match' found" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			candidate = Factory(:candidate_control,
				:related_patid => case_study_subject.reload.patid,
					:updated_at => ( Date.today - 2.days ) )
			duplicate = Factory(:study_subject,
				:sex => candidate.sex,
				:dob => candidate.dob,
				:mother_maiden_name => candidate.mother_maiden_name)
			page.visit related_subject_path(case_study_subject.id)
			click_link 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !page.has_css?('div.possible_duplicates')
			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
			} } } } } } }

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????

			assert page.has_css?("p.flash#error")
			assert_equal current_path, candidate_control_path(candidate)
			assert page.has_css?('div.possible_duplicates')

			#	don't choose a duplicate
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'No Match'
				sleep 2	#	If I don't sleep in capybara, the counts don't change???
			} } } } } } }

			assert_candidate_assigned_and_accepted(candidate.reload)
			assert !page.has_css?("p.flash#error")
			assert_equal current_path, related_subject_path(case_study_subject.id)
		end

	end

protected

	def assert_candidate_assigned_and_accepted(candidate)
		assert        !candidate.reject_candidate
		assert         candidate.rejection_reason.blank?
		assert_not_nil candidate.assigned_on
		assert_not_nil candidate.study_subject
		assert_not_nil candidate.study_subject.mother
	end

	def assert_candidate_rejected(candidate)
		assert     candidate.reject_candidate
		assert    !candidate.rejection_reason.blank?
		assert_nil candidate.assigned_on
		assert_nil candidate.study_subject
	end

end
