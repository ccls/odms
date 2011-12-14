require 'integration_test_helper'

class ConsentJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field(
#				"study_subject[subject_languages_attributes][2][other]").visible?	
				#	specify other hidden
#		and not ...
#			assert page.has_field?(
#				"study_subject[subject_languages_attributes][2][other]", 
#					:visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_administrators.each do |cu|

#	consent#edit (shouldn't have a consent#new)

#	TODO this needs fixed somehow
#		everything works as it should, I just foresee that this is
#		not really the desired effect.
		test "should NOT update consent if ineligible reason given and eligible"<<
				" with #{cu} login" do
			study_subject = Factory(:complete_case_study_subject)	# NOTE CASE subject only (for now?) WITH patient as needed on update
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject.id)
#	choose ineligible
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert page.find_field('enrollment[ineligible_reason_id]').visible?
#	choose other reason
			assert !page.find_field('enrollment[ineligible_reason_specify]').visible?
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert page.find_field('enrollment[ineligible_reason_specify]').visible?
#	fill in ineligible reason
			fill_in 'enrollment[ineligible_reason_specify]', :with => 'Just Testing'
#	choose eligible
			select "Yes", :from => 'enrollment[is_eligible]'
#	These fields are now hidden, but still contain user data
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
#	not nested, so this is actually visible.  Should nest this.
#			assert !page.find_field('enrollment[ineligible_reason_specify]').visible?

#	submit
			click_button 'Save'
#	should fail.  I think that I need to disable the hidden fields so that they 
#		are not submitted.  HOWEVER, if they are not submitted and the user
#		legitimately changed something that should removed then, they field won't 
#		be updated and the record may be invalid!  Ahk.  Erg.  Ehh.  Blah!
#		
#puts page.body
#    <p class="flash" id="error">Enrollment update failed</p>
			assert page.has_css?("p.flash#error")

#<div class="errorExplanation" id="errorExplanation"><h2>2 errors prohibited this enrollment from being saved</h2><p>There were problems with the following fields:</p><ul><li>Ineligible reason not allowed if not ineligible</li><li>Ineligible reason specify not allowed</li></ul></div>

		end








		test "should initially show specify other language when other language checked" <<
				" with #{cu} login" do
			study_subject = Factory(:case_study_subject, # NOTE CASE subject only (for now?)
				:subject_languages_attributes => { 
					'0' => { :language_id => Language['other'].id, :other => 'redneck' }})
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject.id)
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
			study_subject = Factory(:case_study_subject) # NOTE CASE subject only (for now?)
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject.id)
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
				@study_subject = Factory(:complete_case_study_subject) # NOTE CASE subject only (for now?) WITH patient as needed on update
			}
			login_as send(cu)
			page.visit edit_study_subject_consent_path(@study_subject.id)
			show_eligibility_criteria_div
			assert_equal current_path, edit_study_subject_consent_path(@study_subject.id)
			assert_page_has_unchecked_language_id('english')
			#	trigger a kickback from Enrollment update failure
			Enrollment.any_instance.stubs(:valid?).returns(false)	#	Could be StudySubject as well.  Doesn't matter.
			click_button 'Save'
			assert page.has_css?("p.flash#error")
			assert_page_has_unchecked_language_id('english')
		end

		test "should preserve destruction of subject_language on edit kickback" <<
				" with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 1 ){
				@study_subject = Factory(:complete_case_study_subject, # NOTE CASE subject only (for now?) WITH patient as needed on update
					:subject_languages_attributes => { 
						'0' => { :language_id => Language['english'].id }})
			}
			login_as send(cu)
			page.visit edit_study_subject_consent_path(@study_subject.id)
			show_eligibility_criteria_div
			assert_equal current_path, edit_study_subject_consent_path(@study_subject.id)
			assert_page_has_checked_language_destroy('english')
			#	trigger a kickback from Enrollment update failure
			Enrollment.any_instance.stubs(:valid?).returns(false)	#	Could be StudySubject as well.  Doesn't matter.
			click_button 'Save'
			assert page.has_css?("p.flash#error")
			assert_page_has_checked_language_destroy('english')
		end

		#	a bit excessive, but rather be excessive than skimp
		test "should preserve checked subject_languages on edit kickback" <<
				" with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 0 ){
				@study_subject = Factory(:complete_case_study_subject) # NOTE CASE subject only (for now?) WITH patient as needed on update
			}
			login_as send(cu)
			page.visit edit_study_subject_consent_path(@study_subject.id)
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
			assert page.has_css?("p.flash#error")
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
			assert page.has_css?("p.flash#error")
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
			assert page.has_css?("p.flash#error")
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
			assert page.has_css?("p.flash#error")
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

		test "should not have toggle eligibility criteria for non-case" <<
				" with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject)
			assert !page.has_css?('div.eligibility_criteria')
			assert  page.has_no_css?('div.eligibility_criteria')
		end

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
#	Doesn't have an id, but could use the text.  Using find().click works just fine.
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
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert page.find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert page.find_field('enrollment[ineligible_reason_id]').visible?

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
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "Don't Know", :from => 'enrollment[is_eligible]'
			assert page.find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "Don't Know", :from => 'enrollment[is_eligible]'
			assert page.find_field('enrollment[ineligible_reason_id]').visible?

#	jQuery('#enrollment_is_eligible').smartShow({
#		what: '#subject_is_eligible',
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
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "Yes", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "Yes", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?

#	jQuery('#enrollment_is_eligible').smartShow({
#		what: '#subject_is_eligible',
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
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "No", :from => 'enrollment[is_eligible]'
			assert page.find_field('enrollment[ineligible_reason_id]').visible?

			assert !page.find_field('enrollment[ineligible_reason_specify]').visible?
#	case sensitive? yep.
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert page.find_field('enrollment[ineligible_reason_specify]').visible?
			select "", :from => 'enrollment[ineligible_reason_id]'
			assert !page.find_field('enrollment[ineligible_reason_specify]').visible?
			select "other", :from => 'enrollment[ineligible_reason_id]'
			assert page.find_field('enrollment[ineligible_reason_specify]').visible?

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
			assert_subject_consented_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_consented_visible
			select "", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_consented_visible

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
			assert_subject_consented_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_consented_visible
			select "", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_consented_visible

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
			assert_subject_consented_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "", :from => 'enrollment[consented]'
			assert_subject_consented_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_consented_hidden

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
			assert_subject_refused_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_refused_visible
			select "", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "No", :from => 'enrollment[consented]'
			assert_subject_refused_visible

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
			assert_subject_refused_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "Yes", :from => 'enrollment[consented]'
			assert_subject_refused_hidden

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
			assert_subject_refused_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "", :from => 'enrollment[consented]'
			assert_subject_refused_hidden
			select "Don't Know", :from => 'enrollment[consented]'
			assert_subject_refused_hidden

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
			assert !page.find_field('enrollment[refusal_reason_id]').visible?
			select "No", :from => 'enrollment[consented]'
			assert page.find_field('enrollment[refusal_reason_id]').visible?

			assert !page.find_field('enrollment[other_refusal_reason]').visible?
#	case sensitive? yep.
			select "other", :from => 'enrollment[refusal_reason_id]'
			assert page.find_field('enrollment[other_refusal_reason]').visible?
			select "", :from => 'enrollment[refusal_reason_id]'
			assert !page.find_field('enrollment[other_refusal_reason]').visible?
			select "other", :from => 'enrollment[refusal_reason_id]'
			assert page.find_field('enrollment[other_refusal_reason]').visible?
#	jQuery('#enrollment_refusal_reason_id').smartShow({
#		what: '.other_refusal_reason.field_wrapper',
#		when: function(){ 
#			return /other/i.test( 
#				$('#enrollment_refusal_reason_id option:selected').text() ) }
#	});
		end

	end

protected

	def show_eligibility_criteria_div
		#	FRICK n FRAK n!  They weren't visible because this was hidden.  Surprised that I was allowed to interact with the hidden checkboxes!!!!!
		#	MUST, MUST, MUST show this div or the languages will always be hidden!
		page.find('a.toggle_eligibility_criteria').click
		assert self.has_css?('div.eligibility_criteria', :visible => true)
	end
	def assert_subject_consented_visible
		assert page.has_css?('#subject_consented', :visible => true)
		assert page.find_field('enrollment[consented_on]').visible?
		assert page.find_field('enrollment[document_version_id]').visible?
	end
	def assert_subject_consented_hidden
		assert page.has_css?('#subject_consented', :visible => false)
		assert !page.find_field('enrollment[consented_on]').visible?
		assert !page.find_field('enrollment[document_version_id]').visible?
	end
	def assert_subject_refused_visible
		assert page.has_css?('#subject_refused', :visible => true)
		assert page.find_field('enrollment[refusal_reason_id]').visible?
		#	can't explicitly say this as it depend if 'other' is selected
		#	assert page.find_field('enrollment[other_refusal_reason]').visible?
	end
	def assert_subject_refused_hidden
		assert page.has_css?('#subject_refused', :visible => false)
		assert !page.find_field('enrollment[refusal_reason_id]').visible?
		#	Can explicitly say this as the field is nested
		assert !page.find_field('enrollment[other_refusal_reason]').visible?
	end

end
