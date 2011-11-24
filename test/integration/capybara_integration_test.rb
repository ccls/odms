#require 'webrat_integration_test_helper'
require 'capybara_integration_test_helper'

#class CapybaraIntegrationTest < ActionController::IntegrationTest
class CapybaraIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

		test "should create new page with #{cu} login" do
			login_as send(cu)
			page.visit new_page_path

			fill_in "page[path]",     :with => "/MyNewPath"
			fill_in "page[menu_en]",  :with => "MyNewMenu"
			fill_in "page[title_en]", :with => "MyNewTitle"
			fill_in "page[body_en]",  :with => "MyNewBody"

			assert_difference('Page.count',1) {
				#	click_button(value)
				page.click_button "Create"	
			}
		end

	end

end
