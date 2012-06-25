require 'integration_test_helper'

class ConsentIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

#	consent#edit (shouldn't have a consent#new)

#	TODO this needs fixed somehow
#		everything works as it should, I just foresee that this is
#		not really the desired effect.
		test "should NOT update consent if ineligible reason given and eligible"<<
				" with #{cu} login" do
			study_subject = Factory(:complete_case_study_subject)	# NOTE CASE subject only (for now?) WITH patient as needed on update
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject.id)
#	choose ineligible
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert find_field('enrollment[ineligible_reason_id]').visible?
#	choose other reason
			assert !find_field('enrollment[other_ineligible_reason]').visible?
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert find_field('enrollment[other_ineligible_reason]').visible?
#	fill in ineligible reason
			fill_in 'enrollment[other_ineligible_reason]', :with => 'Just Testing'
#	choose eligible
			select "Yes", :from => 'enrollment[is_eligible]'
#	These fields are now hidden, but still contain user data
			assert !find_field('enrollment[ineligible_reason_id]').visible?
#	not nested, so this is actually visible.  Should nest this.
#			assert !find_field('enrollment[other_ineligible_reason]').visible?

#	submit
			click_button 'Save'
#	should fail.  I think that I need to disable the hidden fields so that they 
#		are not submitted.  HOWEVER, if they are not submitted and the user
#		legitimately changed something that should removed then, they field won't 
#		be updated and the record may be invalid!  Ahk.  Erg.  Ehh.  Blah!
#		
#puts body
#    <p class="flash" id="error">Enrollment update failed</p>
			assert has_css?("p.flash.error")

#<div class="errorExplanation" id="errorExplanation"><h2>2 errors prohibited this enrollment from being saved</h2><p>There were problems with the following fields:</p><ul><li>Ineligible reason not allowed if not ineligible</li><li>Ineligible reason specify not allowed</li></ul></div>

		end








		test "should initially show specify other language when other language checked" <<
				" with #{cu} login" do
			# NOTE CASE subject only (for now?)
			study_subject = Factory(:case_study_subject, 
				:subject_languages_attributes => { 
					'0' => { :language_id => Language['other'].id, :other_language => 'redneck' }})
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject.id)
			show_eligibility_criteria_div
			assert_page_has_unchecked_language_id('english')
			assert_page_has_unchecked_language_id('spanish')
			assert_page_has_checked_language_destroy('other')
			assert_other_language_visible
			uncheck(language_input_id('other','_destroy'))
			assert_other_language_hidden
			check(language_input_id('other','_destroy'))
			assert_other_language_visible
			uncheck(language_input_id('other','_destroy'))
			assert_other_language_hidden
		end

		test "should toggle specify other language when other language checked" <<
				" with #{cu} login" do
			# NOTE CASE subject only (for now?)
			study_subject = Factory(:case_study_subject) 
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject.id)
			show_eligibility_criteria_div
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
			check(language_input_id('other'))
			assert_page_has_checked_language_id('other')
			assert_other_language_visible
			uncheck(language_input_id('other'))
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
		end

		test "should preserve creation of subject_language on edit kickback" <<
				" with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 0 ){
				# NOTE CASE subject only (for now?) WITH patient as needed on update
				@study_subject = Factory(:complete_case_study_subject) 
			}
			login_as send(cu)
			visit edit_study_subject_consent_path(@study_subject.id)
			show_eligibility_criteria_div
			assert_equal current_path, edit_study_subject_consent_path(@study_subject.id)
			assert_page_has_unchecked_language_id('english')
			#	trigger a kickback from Enrollment update failure
			#	Could be StudySubject as well.  Doesn't matter.
			Enrollment.any_instance.stubs(:valid?).returns(false)	
			click_button 'Save'
			assert has_css?("p.flash.error")
			assert_page_has_unchecked_language_id('english')
		end

		test "should preserve destruction of subject_language on edit kickback" <<
				" with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 1 ){
				# NOTE CASE subject only (for now?) WITH patient as needed on update
				@study_subject = Factory(:complete_case_study_subject, 
					:subject_languages_attributes => { 
						'0' => { :language_id => Language['english'].id }})
			}
			login_as send(cu)
			visit edit_study_subject_consent_path(@study_subject.id)
			show_eligibility_criteria_div
			assert_equal current_path, edit_study_subject_consent_path(@study_subject.id)
			assert_page_has_checked_language_destroy('english')
			#	trigger a kickback from Enrollment update failure
			#	Could be StudySubject as well.  Doesn't matter.
			Enrollment.any_instance.stubs(:valid?).returns(false)	
			click_button 'Save'
			assert has_css?("p.flash.error")
			assert_page_has_checked_language_destroy('english')
		end

		#	a bit excessive, but rather be excessive than skimp
		test "should preserve checked subject_languages on edit kickback" <<
				" with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 0 ){
				# NOTE CASE subject only (for now?) WITH patient as needed on update
				@study_subject = Factory(:complete_case_study_subject) 
			}
			login_as send(cu)
			visit edit_study_subject_consent_path(@study_subject.id)
			show_eligibility_criteria_div

			assert_equal current_path, edit_study_subject_consent_path(@study_subject.id)
			assert_page_has_unchecked_language_id('english')
			assert_page_has_unchecked_language_id('spanish')
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden

			#	trigger a kickback from Enrollment update failure
			Enrollment.any_instance.stubs(:valid?).returns(false)

			check(language_input_id('english'))
			assert_page_has_checked_language_id('english')
			click_button 'Save'
			assert has_css?("p.flash.error")
			show_eligibility_criteria_div
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert_page_has_checked_language_id('english')	#	still checked!
			assert_page_has_unchecked_language_id('spanish')
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden

			uncheck(language_input_id('english'))
			assert_page_has_unchecked_language_id('english')
			click_button 'Save'
			assert has_css?("p.flash.error")
			show_eligibility_criteria_div
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert_page_has_unchecked_language_id('english')	#	still unchecked!
			assert_page_has_unchecked_language_id('spanish')
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden

			check(language_input_id('spanish'))
			assert_page_has_checked_language_id('spanish')
			click_button 'Save'
			assert has_css?("p.flash.error")
			show_eligibility_criteria_div
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert_page_has_unchecked_language_id('english')
			assert_page_has_checked_language_id('spanish')	#	still checked
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden

			uncheck(language_input_id('spanish'))
			assert_page_has_unchecked_language_id('spanish')

			check(language_input_id('other'))
			assert_page_has_checked_language_id('other')
			assert_other_language_visible

			click_button 'Save'
			assert has_css?("p.flash.error")
			show_eligibility_criteria_div
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert_page_has_unchecked_language_id('english')
			assert_page_has_unchecked_language_id('spanish')
			assert_page_has_checked_language_id('other')	#	still checked!
			assert_other_language_visible

			uncheck(language_input_id('other'))
			assert_page_has_unchecked_language_id('other')
			assert_other_language_hidden
			check(language_input_id('other'))
			assert_page_has_checked_language_id('other')
			assert_other_language_visible
		end

		test "should not have toggle eligibility criteria on show for non-case" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit study_subject_consent_path(study_subject)
			assert !has_css?('div#eligibility_criteria')
			assert  has_no_css?('div#eligibility_criteria')
		end

		test "should not have toggle eligibility criteria on edit for non-case" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert !has_css?('div#eligibility_criteria')
			assert  has_no_css?('div#eligibility_criteria')
		end

		test "should toggle eligibility criteria on show screen with #{cu} login" do
			#	NOTE only exists for case subjects WITH PATIENT
			study_subject = Factory(:complete_case_study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit study_subject_consent_path(study_subject)
			assert has_css?('div#eligibility_criteria', :visible => false)
			find('a.toggles_eligibility_criteria').click
			assert has_css?('div#eligibility_criteria', :visible => true)
			find('a.toggles_eligibility_criteria').click
			assert has_css?('div#eligibility_criteria', :visible => false)
		end

		test "should toggle eligibility criteria on edit screen with #{cu} login" do
			#	NOTE only exists for case subjects
			study_subject = Factory(:case_study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert has_css?('div#eligibility_criteria', :visible => false)
			find('a.toggles_eligibility_criteria').click
			assert has_css?('div#eligibility_criteria', :visible => true)
			find('a.toggles_eligibility_criteria').click
			assert has_css?('div#eligibility_criteria', :visible => false)
		end

		test "should show ineligible_reason selector if 'No' for is_eligible" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert find_field('enrollment[ineligible_reason_id]').visible?
		end

		test "should show ineligible_reason selector if 'Don't Know' for is_eligible" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "Don't Know", :from => 'enrollment[is_eligible]'
			assert find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "Don't Know", :from => 'enrollment[is_eligible]'
			assert find_field('enrollment[ineligible_reason_id]').visible?
		end

		test "should NOT show ineligible_reason selector if 'Yes' for is_eligible" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "Yes", :from => 'enrollment[is_eligible]'
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "Yes", :from => 'enrollment[is_eligible]'
			assert !find_field('enrollment[ineligible_reason_id]').visible?
		end

		test "should show other_ineligible_reason if 'Other' reason selected" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert !find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert find_field('enrollment[ineligible_reason_id]').visible?

			assert !find_field('enrollment[other_ineligible_reason]').visible?
#	case sensitive? yep.
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert find_field('enrollment[other_ineligible_reason]').visible?
			select "", :from => 'enrollment[ineligible_reason_id]'
			assert !find_field('enrollment[other_ineligible_reason]').visible?
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert find_field('enrollment[other_ineligible_reason]').visible?
		end

		test "should show subject_consented if consent is 'Yes'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_subject_consented_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_consented_visible
			select "", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_consented_visible
		end

		test "should show subject_consented if consent is 'No'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_subject_consented_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_consented_visible
			select "", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_consented_visible
		end

		test "should NOT show subject_consented if consent is 'Don't Know'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_subject_consented_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
		end

		test "should show subject_refused if consent is 'No'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_subject_refused_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_refused_visible
			select "", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_refused_visible
		end

		test "should NOT show subject_refused if consent is 'Yes'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_subject_refused_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
		end

		test "should NOT show subject_refused if consent is 'Don't Know'"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert_subject_refused_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
		end


		test "should show other_refusal_reason if 'Other' reason selected"<<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			consent = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil consent
			login_as send(cu)
			visit edit_study_subject_consent_path(study_subject)
			assert !find_field('enrollment[refusal_reason_id]').visible?
			select "No", :from => 'enrollment[consented]'
			assert find_field('enrollment[refusal_reason_id]').visible?

			assert !find_field('enrollment[other_refusal_reason]').visible?
#	case sensitive? yep.
			select "other", :from => 'enrollment[refusal_reason_id]'
			assert find_field('enrollment[other_refusal_reason]').visible?
			select "", :from => 'enrollment[refusal_reason_id]'
			assert !find_field('enrollment[other_refusal_reason]').visible?
			select "other", :from => 'enrollment[refusal_reason_id]'
			assert find_field('enrollment[other_refusal_reason]').visible?
		end

	end

protected

	def show_eligibility_criteria_div
		#	FRICK n FRAK n!  They weren't visible because this was hidden.  
		#	Surprised that I was allowed to interact with the hidden checkboxes!!!!!
		#	MUST, MUST, MUST show this div or the languages will always be hidden!
		find('a.toggler.toggles_eligibility_criteria').click
		assert self.has_css?('div#eligibility_criteria', :visible => true)
	end
	def assert_subject_consented_visible
		assert has_css?('#subject_consented', :visible => true)
		assert find_field('enrollment[consented_on]').visible?
		assert find_field('enrollment[document_version_id]').visible?
	end
	def assert_subject_consented_hidden
		assert has_css?('#subject_consented', :visible => false)
		assert !find_field('enrollment[consented_on]').visible?
		assert !find_field('enrollment[document_version_id]').visible?
	end
	def assert_subject_refused_visible
		assert has_css?('#subject_refused', :visible => true)
		assert find_field('enrollment[refusal_reason_id]').visible?
		#	can't explicitly say this as it depend if 'other' is selected
		#	assert find_field('enrollment[other_refusal_reason]').visible?
	end
	def assert_subject_refused_hidden
		assert has_css?('#subject_refused', :visible => false)
		assert !find_field('enrollment[refusal_reason_id]').visible?
		#	Can explicitly say this as the field is nested
		assert !find_field('enrollment[other_refusal_reason]').visible?
	end

end
