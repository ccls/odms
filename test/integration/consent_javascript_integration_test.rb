require 'integration_test_helper'

class ConsentJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#	consent#edit (shouldn't have a consent#new)

		#	jQuery('a.toggle_eligibility_criteria').togglerFor('.eligibility_criteria');
		test "should toggle eligibility criteria with #{cu} login" do

			#	NOTE only exists for case subjects
			study_subject = Factory(:case_study_subject)

			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('div.eligibility_criteria', :visible => false)
#Capybara::ElementNotFound: no link with title, id or text '.toggle_eligibility_criteria' found
#			click_link '.toggle_eligibility_criteria'
			find('a.toggle_eligibility_criteria').click
			assert page.has_css?('div.eligibility_criteria', :visible => true)
			find('a.toggle_eligibility_criteria').click
			assert page.has_css?('div.eligibility_criteria', :visible => false)
		end

		test "should show ineligible_reason selector if 'No' for is_eligible" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "No", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => true)
			select "", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "No", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => true)

#	jQuery('#enrollment_is_eligible').smartShow({
#		what: '.ineligible_reason_id.field_wrapper',
#		when: function(){ 
#			return /no/i.test( 
#				$('#enrollment_is_eligible option:selected').text() ) }
#	});
		end

		test "should show ineligible_reason selector if 'Don't Know' for is_eligible" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "Don't Know", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => true)
			select "", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "Don't Know", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => true)

#	jQuery('#enrollment_is_eligible').smartShow({
#		what: '.ineligible_reason_id.field_wrapper',
#		when: function(){ 
#			return /no/i.test( 
#				$('#enrollment_is_eligible option:selected').text() ) }
#	});
		end

		test "should NOT show ineligible_reason selector if 'Yes' for is_eligible" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "Yes", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "Yes", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)

#	jQuery('#enrollment_is_eligible').smartShow({
#		what: '.ineligible_reason_id.field_wrapper',
#		when: function(){ 
#			return /no/i.test( 
#				$('#enrollment_is_eligible option:selected').text() ) }
#	});
		end

		test "should show ineligible_reason_specify if 'Other' reason selected" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => false)
			select "No", :from => 'enrollment[is_eligible]'
			assert page.has_field?('enrollment[ineligible_reason_id]', :visible => true)

			assert page.has_field?('enrollment[ineligible_reason_specify]', :visible => false)
#	case sensitive? yep.
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert page.has_field?('enrollment[ineligible_reason_specify]', :visible => true)
			select "", :from => 'enrollment[ineligible_reason_id]'
			assert page.has_field?('enrollment[ineligible_reason_specify]', :visible => false)
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert page.has_field?('enrollment[ineligible_reason_specify]', :visible => true)

#	jQuery('#enrollment_ineligible_reason_id').smartShow({
#		what: '.ineligible_reason_specify.field_wrapper',
#		when: function(){ 
#			return /other/i.test( 
#				$('#enrollment_ineligible_reason_id option:selected').text() ) }
#	});
		end

		test "should show subject_consented if consent is 'Yes'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('#subject_consented', :visible => false)
			select "Yes", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => true)
			select "", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => false)
			select "Yes", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => true)

#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_consented',
#		when: function(){ 
#			return /^(yes|no)/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
		end

		test "should show subject_consented if consent is 'No'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('#subject_consented', :visible => false)
			select "No", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => true)
			select "", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => false)
			select "No", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => true)

#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_consented',
#		when: function(){ 
#			return /^(yes|no)/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
		end

		test "should NOT show subject_consented if consent is 'Don't Know'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('#subject_consented', :visible => false)
			select "Don't Know", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => false)
			select "", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => false)
			select "Don't Know", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_consented', :visible => false)

#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_consented',
#		when: function(){ 
#			return /^(yes|no)/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
		end

		test "should show subject_refused if consent is 'No'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('#subject_refused', :visible => false)
			select "No", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => true)
			select "", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)
			select "No", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => true)

#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_refused',
#		when: function(){ 
#			return /^no/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
		end

		test "should NOT show subject_refused if consent is 'Yes'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('#subject_refused', :visible => false)
			select "Yes", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)
			select "", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)
			select "Yes", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)

#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_refused',
#		when: function(){ 
#			return /^no/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
		end

		test "should NOT show subject_refused if consent is 'Don't Know'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_css?('#subject_refused', :visible => false)
			select "Don't Know", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)
			select "", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)
			select "Don't Know", :from => 'enrollment[consented]'
			assert page.has_css?('#subject_refused', :visible => false)

#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_refused',
#		when: function(){ 
#			return /^no/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
		end


		test "should show other_refusal_reason if 'Other' reason selected"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert page.has_field?('enrollment[refusal_reason_id]', :visible => false)
			select "No", :from => 'enrollment[consented]'
			assert page.has_field?('enrollment[refusal_reason_id]', :visible => true)

			assert page.has_field?('enrollment[other_refusal_reason]', :visible => false)
#	case sensitive? yep.
			select "other", :from => 'enrollment[refusal_reason_id]'
			assert page.has_field?('enrollment[other_refusal_reason]', :visible => true)
			select "", :from => 'enrollment[refusal_reason_id]'
			assert page.has_field?('enrollment[other_refusal_reason]', :visible => false)
			select "other", :from => 'enrollment[refusal_reason_id]'
			assert page.has_field?('enrollment[other_refusal_reason]', :visible => true)
#	jQuery('#enrollment_refusal_reason_id').smartShow({
#		what: '.other_refusal_reason.field_wrapper',
#		when: function(){ 
#			return /other/i.test( 
#				$('#enrollment_refusal_reason_id option:selected').text() ) }
#	});
		end

	end

end
