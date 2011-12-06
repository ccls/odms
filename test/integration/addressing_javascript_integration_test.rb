require 'integration_test_helper'

class AddressingJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_administrators.each do |cu|

		test "addressing#edit should update blank address info on zip code change" <<
				" with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			fill_in "addressing[address_attributes][city]",  :with => ""
			fill_in "addressing[address_attributes][county]",  :with => ""
			select "", :from => 'addressing[address_attributes][state]'
			fill_in "addressing[address_attributes][zip]",  :with => ""
			assert page.find_field("addressing[address_attributes][city]").value.blank?
			assert page.find_field("addressing[address_attributes][county]").value.blank?
			assert page.find_field("addressing[address_attributes][state]").value.blank?
			assert page.find_field("addressing[address_attributes][zip]").value.blank?

			fill_in "addressing[address_attributes][zip]",  :with => "17857"
			#	I don't think that the change event get triggered correctly
			#	in the test environment.
			#
			#	This may happen as the browser
			#	actually exists and perhaps me coding while the browser is trying to
			#	test takes focus away from it?  Can I force the browser into the background?
			#
			#	maybe "change" isn't the appropriate event trigger for this?
			#	explicitly trigger the change event.
			#	If the user running the tests is using the machine,
			#	it can inhibit this test.  Don't know why.
			#	It will send a blank zip code which will result in
			#	no field updates.
#	When using capybara-webkit, this isn't necessary!  Yay!
#		If we change back to selenium, this may need uncommented.
#			page.execute_script("$('#addressing_address_attributes_zip').change()" );
#			sleep 1

			assert_equal 'NORTHUMBERLAND',
				page.find_field("addressing[address_attributes][city]").value
			assert_equal 'Northumberland',
				page.find_field("addressing[address_attributes][county]").value
			assert_equal 'PA',
				page.find_field("addressing[address_attributes][state]").value
			assert_equal '17857',
				page.find_field("addressing[address_attributes][zip]").value
		end

		test "addressing#edit should show why_invalid when is_valid is changed to 'No'" <<
				" with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert !page.find_field('addressing[why_invalid]').visible?
			select "No", :from => 'addressing[is_valid]'
			assert page.find_field('addressing[why_invalid]').visible?
			select "", :from => 'addressing[is_valid]'
			assert !page.find_field('addressing[why_invalid]').visible?
			select "No", :from => 'addressing[is_valid]'
			assert page.find_field('addressing[why_invalid]').visible?
		end

		test "addressing#edit should show why_invalid when is_valid is changed to" <<
				" 'Don't Know' with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert !page.find_field('addressing[why_invalid]').visible?
			select "Don't Know", :from => 'addressing[is_valid]'
			assert page.find_field('addressing[why_invalid]').visible?
			select "", :from => 'addressing[is_valid]'
			assert !page.find_field('addressing[why_invalid]').visible?
			select "Don't Know", :from => 'addressing[is_valid]'
			assert page.find_field('addressing[why_invalid]').visible?
		end

		test "addressing#edit should show how_verified when is_verified is checked" <<
				" with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert !page.find_field('addressing[how_verified]').visible?
			check 'addressing[is_verified]'
			assert page.find_field('addressing[how_verified]').visible?
			uncheck 'addressing[is_verified]'
			assert !page.find_field('addressing[how_verified]').visible?
			check 'addressing[is_verified]'
			assert page.find_field('addressing[how_verified]').visible?
		end

		test "addressing#edit should show data_source_other when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert !page.find_field('addressing[data_source_other]').visible?
			select "Other Source", :from => 'addressing[data_source_id]'
			assert page.find_field('addressing[data_source_other]').visible?
			select "", :from => 'addressing[data_source_id]'
			assert !page.find_field('addressing[data_source_other]').visible?
			select "Other Source", :from => 'addressing[data_source_id]'
			assert page.find_field('addressing[data_source_other]').visible?
		end

		test "addressing#edit should show subject_moved when residence address" <<
				" current_address is changed to 'No' with #{cu} login" do
			addressing = Factory(:current_residence_addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert !page.find_field('addressing[subject_moved]').visible?
			select "No", :from => 'addressing[current_address]'
			assert page.find_field('addressing[subject_moved]').visible?
			select "", :from => 'addressing[current_address]'
			assert !page.find_field('addressing[subject_moved]').visible?
			select "No", :from => 'addressing[current_address]'
			assert page.find_field('addressing[subject_moved]').visible?
		end

		test "addressing#edit should NOT show subject_moved when residence address" <<
				" current_address is changed to 'Don't Know' with #{cu} login" do
			addressing = Factory(:current_residence_addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert !page.find_field('addressing[subject_moved]').visible?
			select "Don't Know", :from => 'addressing[current_address]'
			assert !page.find_field('addressing[subject_moved]').visible?
			select "", :from => 'addressing[current_address]'
			assert !page.find_field('addressing[subject_moved]').visible?
			select "Don't Know", :from => 'addressing[current_address]'
			assert !page.find_field('addressing[subject_moved]').visible?
		end

#	addressing#new

		test "addressing#new should show confirm when new residence addressing is" <<
				" submitted with state not 'CA' and #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit new_study_subject_addressing_path(study_subject)
			#	residence address and NOT in 'CA'
			select 'PA', :from => "addressing[address_attributes][state]"
			select 'residence', :from => "addressing[address_attributes][address_type_id]"

#	capybara-webkit doesn't have page.driver.browser.switch_to
#		so if we're using it, we'll have to just ignore the pop-up.
#	Do I need this? 
#		In selenium, the confirm window will cause failures unless dealt with.
#		In webkit, the confirm window will do nothing making this test pointless.
			page.evaluate_script('window.confirm = function() { return false; }')

			click_button 'Save'

#
#	TODO with webkit, how do I test if a confirm window popped up????
#		I could make this a legitimate address that would normally
#			create an addressing/address and simply test that none were
#			actually create because the browser kicked back?
#
			#	Without overriding the confirm function, clicking save will submit
			#		and the current_path would be /study_subjects/:id/addressings
			#	When confirm returns false, it will stay at same path.
			#	Essentially, this works by testing that it didn't go anywhere.
			assert_equal current_path,
				new_study_subject_addressing_path(study_subject)


			#	This should raise a confirm window which will need dealt with.
			#	press Cancel by ...
			#		page.driver.browser.switch_to.alert.dismiss
			#	press OK by ...
			#		page.driver.browser.switch_to.alert.accept
			#	Or, before the popup is triggered, override the function with either ...
			#		page.evaluate_script('window.confirm = function() { return false; }')
			#		page.evaluate_script('window.confirm = function() { return true; }')
			#	This will actually stop the window from appearing.
			#	You won't be able to check the text if done this way.

#	capybara-webkit doesn't have page.driver.browser.switch_to
#		so if we're using it, we can't do this.
#			assert_equal "This address is not in CA and will make study_subject ineligible.  Do you want to continue?", page.driver.browser.switch_to.alert.text
#			page.driver.browser.switch_to.alert.dismiss
		end

		test "addressing#new should update blank city, state and county on zip code" <<
				" change with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit new_study_subject_addressing_path(study_subject)
			assert page.find_field("addressing[address_attributes][city]").value.blank?
			assert page.find_field("addressing[address_attributes][county]").value.blank?
			assert page.find_field("addressing[address_attributes][state]").value.blank?
			assert page.find_field("addressing[address_attributes][zip]").value.blank?

			fill_in "addressing[address_attributes][zip]",  :with => "17857"
			#	I don't think that the change event get triggered correctly
			#	in the test environment.
			#
			#	This may happen as the browser
			#	actually exists and perhaps me coding while the browser is trying to
			#	test takes focus away from it?  Can I force the browser into the background?
			#
			#	maybe "change" isn't the appropriate event trigger for this?
			#	explicitly trigger the change event.
			#	If the user running the tests is using the machine,
			#	it can inhibit this test.  Don't know why.
			#	It will send a blank zip code which will result in
			#	no field updates.
#	When using capybara-webkit, this isn't necessary!  Yay!
#		If we change back to selenium, this may need uncommented.
#			page.execute_script("$('#addressing_address_attributes_zip').change()" );
#			sleep 1

			assert_equal 'NORTHUMBERLAND',
				page.find_field("addressing[address_attributes][city]").value
			assert_equal 'Northumberland',
				page.find_field("addressing[address_attributes][county]").value
			assert_equal 'PA',
				page.find_field("addressing[address_attributes][state]").value
			assert_equal '17857',
				page.find_field("addressing[address_attributes][zip]").value
		end

	end

end
