require 'integration_test_helper'

class CaseIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

#		test "should preselect waivered organization_id from new case with #{cu} login" do
#			login_as send(cu)
#			visit new_case_path
#			assert_equal new_case_path, current_path
#
#			hospital = Hospital.active.waivered.first
#
#			select hospital.organization.to_s, :from => "hospital_id"
#			click_button "New Case"	
#
##	current_url is not following redirect
##	This used to work in rails 2 and does work in the functional tests.
##	TODO the page content appears correct, but the url is cases_path
##			assert_match /http(s)?:\/\/.*\/waivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url
#
#			#	This isn't perfect, but it does test that the redirect is correct.
#			#	If I can't test that I've been redirected, test the page content.
#			assert_select HTML::Document.new(body).root, 'div#main h3', 
#				:text => "Rapid Ascertainment Form (RAF) - waiver version"
#
#			#	capybara apparently won't find a field by name that is
#			#		type=hidden, however, finding it by css works.
#			assert_equal hospital.organization_id.to_s,
#				find('#study_subject_patient_attributes_organization_id').value
#		end
#
#		test "should preselect nonwaivered organization_id from new case with #{cu} login" do
#			login_as send(cu)
#			visit new_case_path
#			assert_equal new_case_path, current_path
#
#			hospital = Hospital.active.nonwaivered.first
#			select hospital.organization.to_s, :from => "hospital_id"
#			click_button "New Case"	
#
##	current_url is not following redirect
##	This used to work in rails 2 and does work in the functional tests.
##	TODO the page content appears correct, but the url is cases_path
##			assert_match /http(s)?:\/\/.*\/nonwaivered\/new\?study_subject.*patient_attributes.*organization_id.*=\d+/, current_url
#
#			#	This isn't perfect, but it does test that the redirect is correct.
#			#	If I can't test that I've been redirected, test the page content.
#			assert_select HTML::Document.new(body).root, 'div#main h3', 
#				:text => "Rapid Ascertainment Form (RAF) - non-waiver version"
#
#			#	capybara apparently won't find a field by name that is
#			#		type=hidden, however, finding it by css works.
#			assert_equal hospital.organization_id.to_s,
#				find('#study_subject_patient_attributes_organization_id').value
#		end

	end

end
__END__
I'm still not clear on whether I need to use "page." or not.
It seems like page == self and is therefore unnecessary.

page.visit =? visit
page.find =? find
page.click =? click
page.body =? body
page.select =? select

current_path and current_url still don't update on a redirect

