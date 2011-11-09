require 'integration_test_helper'

class PatientIntegrationTest < ActionController::IntegrationTest

#	This form may have limited form fields so is worthy of testing

	site_administrators.each do |cu|

		test "should create new patient for case with #{cu} login using webrat" do
			login_as send(cu)
			#	need to set HTTPS for webrat
			header('HTTPS', 'on')
#			visit new_page_path
#			fill_in "page[path]",     :with => "/MyNewPath"
#			fill_in "page[menu_en]",  :with => "MyNewMenu"
#			fill_in "page[title_en]", :with => "MyNewTitle"
#			fill_in "page[body_en]",  :with => "MyNewBody"
#
#			assert_difference('Patient.count',1) {
#				#	click_button(value)
#				click_button "Create"	
#			}
		end

	end

end
