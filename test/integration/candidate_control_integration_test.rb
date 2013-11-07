require 'integration_test_helper'

class CandidateControlIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "should create control for case with no duplicates and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_complete_case_study_subject_with_icf_master_id
			birth_datum = FactoryGirl.create(:control_birth_datum, 
				:master_id => case_study_subject.icf_master_id )
			candidate = birth_datum.candidate_control
			candidate.update_attributes( :updated_at => ( Date.current - 2.days ) )

			visit study_subject_related_subjects_path(case_study_subject.id)
			assert_equal current_path, study_subject_related_subjects_path(case_study_subject.id)
			click_button 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !has_css?('div.possible_duplicates')

			#	realistically, must 'choose' a radio button by id as the name is not 
			#	likely unique as most radio buttons are part of a 'group' and the 
			#	group is defined by a shared name value.
			choose 'candidate_control_reject_candidate_false'
			# fill_in 'candidate_control_rejection_reason', :with => ''
			#	'candidate_control[rejection_reason]' will most likely
			#	be prerejected with "DOB does not match."
			fill_in 'candidate_control[rejection_reason]', :with => ''

			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
				#	out of icf master ids warning
				wait_until { has_css?("p.flash.warn") }
			} } } } } }

			#	out of icf master ids warning
			assert has_css?("p.flash.warn")
			assert_candidate_assigned_and_accepted(candidate.reload)
			assert !has_css?("p.flash.error")
			assert_equal current_path, study_subject_related_subjects_path(case_study_subject.id)
		end

		test "should NOT create control subject if duplicate subject" <<
				" with #{cu} login and 'Match Found' and no duplicate_id" do
			login_as send(cu)
			case_study_subject = create_complete_case_study_subject_with_icf_master_id
			birth_datum = FactoryGirl.create(:control_birth_datum, 
				:master_id => case_study_subject.icf_master_id )
			candidate = birth_datum.candidate_control
			candidate.update_attributes( :updated_at => ( Date.current - 2.days ) )
			duplicate = FactoryGirl.create(:study_subject,
				:sex => candidate.sex,
				:dob => candidate.dob,
				:mother_maiden_name => candidate.mother_maiden_name)
			visit study_subject_related_subjects_path(case_study_subject.id)
			assert_equal current_path, study_subject_related_subjects_path(case_study_subject.id)
			click_button 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !has_css?('div.possible_duplicates')
			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
				wait_until { has_css?("p.flash.error") }
			} } } } } }

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????
			assert has_css?("p.flash.error")
			assert_equal current_path, candidate_control_path(candidate)
			assert has_css?('div.possible_duplicates')

			#	don't choose a duplicate
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'Match Found'
				wait_until { has_css?("p.flash.error") }
			} } } } } }
			assert has_css?('div.possible_duplicates')
			assert has_css?("p.flash.error")
			assert has_css?("p.flash.warn")

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
			case_study_subject = create_complete_case_study_subject_with_icf_master_id
			birth_datum = FactoryGirl.create(:control_birth_datum, 
				:master_id => case_study_subject.icf_master_id )
			candidate = birth_datum.candidate_control
			candidate.update_attributes( :updated_at => ( Date.current - 2.days ) )
			duplicate = FactoryGirl.create(:study_subject,
				:sex => candidate.sex,
				:dob => candidate.dob,
				:mother_maiden_name => candidate.mother_maiden_name)
			visit study_subject_related_subjects_path(case_study_subject.id)
			click_button 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !has_css?('div.possible_duplicates')
			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
				wait_until { has_css?("p.flash.error") }
			} } } } } }

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????
			assert has_css?("p.flash.error")
			assert_equal current_path, candidate_control_path(candidate)
			assert has_css?('div.possible_duplicates')

			#	choose a duplicate
			choose "duplicate_id_#{duplicate.id}"
			#	no new records, just a modified candidate_control record
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'Match Found'
				wait_until { 
					current_path == study_subject_related_subjects_path(case_study_subject.id) }

				#	i still don't know why some redirects are followed by capybara and some aren't

			} } } } } }

			assert_candidate_rejected(candidate.reload)
			# as the created duplicate is not explicitly a case
			# the reason will be because it is a control
			assert_match /ineligible control - control already exists in system/,
				candidate.rejection_reason
			assert !has_css?("p.flash.error")
			assert_equal current_path, study_subject_related_subjects_path(case_study_subject.id)
		end

		test "should create control subject if duplicate subject" <<
				" with #{cu} login and 'No Match' found" do
			login_as send(cu)
			case_study_subject = create_complete_case_study_subject_with_icf_master_id
			birth_datum = FactoryGirl.create(:control_birth_datum, 
				:master_id => case_study_subject.icf_master_id )
			candidate = birth_datum.candidate_control
			candidate.update_attributes( :updated_at => ( Date.current - 2.days ) )
			duplicate = FactoryGirl.create(:study_subject,
				:sex => candidate.sex,
				:dob => candidate.dob,
				:mother_maiden_name => candidate.mother_maiden_name)
			visit study_subject_related_subjects_path(case_study_subject.id)
			click_button 'add control'

			#	Only one control so should go to it.
			assert_equal current_path, edit_candidate_control_path(candidate)
			assert !has_css?('div.possible_duplicates')
			choose 'candidate_control_reject_candidate_false'
			fill_in 'candidate_control_rejection_reason', :with => ''
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',0) {
			assert_difference('StudySubject.count',0) {
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'continue'
				wait_until { has_css?("p.flash.error") }
			} } } } } }

			#
			#	this kicks back as a render, not a redirect so 
			#	rather than actually being edit_candidate_control_path
			#	it is just candidate_control_path, but there is no
			#	candidate_control show action but it still passes????

			assert has_css?("p.flash.error")
			assert_equal current_path, candidate_control_path(candidate)
			assert has_css?('div.possible_duplicates')

			#	don't choose a duplicate
			assert_difference('PhoneNumber.count',0) {
			assert_difference('Addressing.count',0) {
			assert_difference('Patient.count',0) {
			assert_difference('Enrollment.count',2) {
			assert_difference('StudySubject.count',2) {
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
				click_button 'No Match'
				#	no icf master ids warning
				wait_until { has_css?("p.flash.warn") }
			} } } } } }

			assert has_css?("p.flash.warn")
			assert_candidate_assigned_and_accepted(candidate.reload)
			assert !has_css?("p.flash.error")
			assert_equal current_path, study_subject_related_subjects_path(case_study_subject.id)
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
#		assert    !candidate.rejection_reason.blank?
		assert     candidate.rejection_reason.present?
		assert_nil candidate.assigned_on
		assert_nil candidate.study_subject
	end

	def create_complete_case_study_subject_with_icf_master_id
		study_subject = FactoryGirl.create(:complete_case_study_subject)
		assert_nil study_subject.icf_master_id
		imi = FactoryGirl.create(:icf_master_id,:icf_master_id => 'ICASE4BIR')
		study_subject.assign_icf_master_id
		assert_not_nil study_subject.icf_master_id
		assert_equal 'ICASE4BIR', study_subject.icf_master_id
		study_subject
	end

end
