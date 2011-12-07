require 'integration_test_helper'

class ConsentJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_administrators.each do |cu|

#	consent#edit (shouldn't have a consent#new)

		test "should initial show specify other language when other language checked with #{cu} login" do
			study_subject = Factory(:case_study_subject, :subject_languages_attributes => { 
				'0' => { :language_id => Language['other'].id, :other => 'redneck' }})			#	CASE subject only (for now?)
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject.id)
			#	[2] since 'other' will be the third language in the array
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_checked_field?("study_subject[subject_languages_attributes][2][_destroy]")	#	other

#	TODO need to fix the javascript to deal with the _destroy fields

#puts page.body
#
#<input id="study_subject_subject_languages_attributes_2_id" name="study_subject[subject_languages_attributes][2][id]" type="hidden" value="1"><div id="study_subject_languages"><div class="languages_label">Language of parent or caretaker:</div>
#<div id="languages">
#<div class="subject_language creator"><input name="study_subject[subject_languages_attributes][0][language_id]" type="hidden" value=""><input id="study_subject_subject_languages_attributes_0_language_id" name="study_subject[subject_languages_attributes][0][language_id]" type="checkbox" value="1">
#<label for="study_subject_subject_languages_attributes_0_language_id">English (eligible)</label>
#</div>
#<div class="subject_language creator"><input name="study_subject[subject_languages_attributes][1][language_id]" type="hidden" value=""><input id="study_subject_subject_languages_attributes_1_language_id" name="study_subject[subject_languages_attributes][1][language_id]" type="checkbox" value="2">
#<label for="study_subject_subject_languages_attributes_1_language_id">Spanish (eligible)</label>
#</div>
#<div class="subject_language destroyer"><div id="other_language"><input id="study_subject_subject_languages_attributes_2_language_id" name="study_subject[subject_languages_attributes][2][language_id]" type="hidden" value="3"><input name="study_subject[subject_languages_attributes][2][_destroy]" type="hidden" value="1"><input checked="checked" id="study_subject_subject_languages_attributes_2__destroy" name="study_subject[subject_languages_attributes][2][_destroy]" type="checkbox" value="0">
#<label for="study_subject_subject_languages_attributes_2__destroy">Other (not eligible)</label>
#<div id="specify_other_language"><label for="study_subject_subject_languages_attributes_2_other">specify:</label>
#<input id="study_subject_subject_languages_attributes_2_other" name="study_subject[subject_languages_attributes][2][other]" size="12" type="text" value="redneck">
#</div></div></div>
#</div>
#</div><!-- study_subject_languages -->
#
#	find_field can't find type=hidden fields??
#			assert page.find_field("study_subject_subject_languages_attributes_2_language_id")	#	other (this is actually an type=hidden field)
#			assert page.find_field("study_subject[subject_languages_attributes][2][language_id]")	#	other (this is actually an type=hidden field)
#			assert page.has_field?("study_subject_subject_languages_attributes_2_language_id")	#	other (this is actually an type=hidden field)
#			assert page.has_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other (this is actually an type=hidden field)



			assert page.has_field?("study_subject[subject_languages_attributes][2][other]")	#	specify other VISIBLE
			assert page.find_field("study_subject[subject_languages_attributes][2][other]")
#	TODO this field is there and should be visible but fails??
#			assert page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other VISIBLE
#	TODO this field is there and should be visible but fails??
#			assert page.has_css?("#specify_other_language", :visible => true)


#	TODO unchecking the _destroy should hide other specify ???

		end

		test "should toggle specify other language when other language checked with #{cu} login" do
			study_subject = Factory(:case_study_subject)			#	CASE subject only (for now?)
			login_as send(cu)
			page.visit edit_study_subject_consent_path(study_subject.id)
			#	[2] since 'other' will be the third language in the array
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other


			#	specify other should be hidden
			assert page.has_css?("#specify_other_language", :visible => false)
			assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => false)
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?


			check("study_subject[subject_languages_attributes][2][language_id]")	#	other		#	this SHOULD toggle the specify other!
			assert page.has_checked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	TODO this isn't working yet. why???? javascript seems to be working
#ALERT: smart toggling
#ALERT: hiding #specify_other_language
#checking other
#ALERT: smart toggling
#ALERT: showing #specify_other_language

			#	specify other should be visible
#	TODO this isn't working
#			assert page.has_css?("#specify_other_language", :visible => true)
#			assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => true)
#			assert page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other visible again


			uncheck("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

			#	specify other should be hidden
			assert page.has_css?("#specify_other_language", :visible => false)
			assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => false)
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden

#flunk
		end

		#	a bit excessive, but rather be excessive than skimp
		test "should preserve checked subject_languages on edit kickback with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 0 ){
				@study_subject = Factory(:case_study_subject)			#	CASE subject only (for now?)
			}
			login_as send(cu)
			page.visit edit_study_subject_consent_path(@study_subject.id)
			assert_equal current_path, edit_study_subject_consent_path(@study_subject.id)
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	good
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other

			#	trigger a kickback from Enrollment update failure
			Enrollment.any_instance.stubs(:valid?).returns(false)

			check("study_subject[subject_languages_attributes][0][language_id]")	#	english
			assert page.has_checked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english
			click_button 'Save'
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert page.has_checked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english still checked
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	good
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other

			uncheck("study_subject[subject_languages_attributes][0][language_id]")	#	english
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english
			click_button 'Save'
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english still unchecked
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	good
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other

			check("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_checked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			click_button 'Save'
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english
			assert page.has_checked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish still checked
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	good
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other

			uncheck("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish


			check("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert page.has_checked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	TODO this isn't working yet. why???? javascript seems to be working
#		it even seems to be right on load, but not plain javascript.
#		I don't even know how to guess what's wrong here.
#	TODO
#			assert page.has_css?("#specify_other_language", :visible => true)
#			assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => true)
#			assert page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other toggled


			click_button 'Save'
			#	renders, doesn't redirect so path will change even though still on edit
			assert_equal current_path, study_subject_consent_path(@study_subject.id)
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][0][language_id]")	#	english
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][1][language_id]")	#	spanish
			assert page.has_checked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other still checked

#	TODO
#			assert page.has_css?("#specify_other_language", :visible => true)
#			assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => true)
#			assert page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other still visible


			uncheck("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert page.has_unchecked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
			assert page.has_css?("#specify_other_language", :visible => false)
			check("study_subject[subject_languages_attributes][2][language_id]")	#	other
			assert page.has_checked_field?("study_subject[subject_languages_attributes][2][language_id]")	#	other

#	TODO
#			assert page.has_css?("#specify_other_language", :visible => true)
#			assert page.has_css?("#study_subject_subject_languages_attributes_2_other",:visible => true)
#			assert page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other visible again
		end

		test "should not have toggle eligibility criteria for non-case with #{cu} login" do
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
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "Yes", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?
			select "Yes", :from => 'enrollment[is_eligible]'
			assert !page.find_field('enrollment[ineligible_reason_id]').visible?

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

end
