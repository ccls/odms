require 'integration_test_helper'

class CapybaraIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

		test "should create new page with #{cu} login" do
#puts "Before login:#{User.all.inspect}"
			login_as send(cu)
#puts "After login:#{User.all.inspect}"
			page.visit new_page_path

#puts "in test connection check"
#puts User.connection.inspect

#puts current_url	#	root_path ????

			fill_in "page[path]",     :with => "/MyNewPath"
			fill_in "page[menu_en]",  :with => "MyNewMenu"
			fill_in "page[title_en]", :with => "MyNewTitle"
			fill_in "page[body_en]",  :with => "MyNewBody"

			assert_difference('Page.count',1) {
				#	click_button(value)
#				page.click_button "Create"	
#	As this is one of my submit_link_tos, ...
#	Selenium::WebDriver::Error::ElementNotDisplayedError: Element is not currently visible and so may not be interacted with
				page.click_link "Create"	
			}
			assert page.has_no_css?('div#somethingthatdoesnotexist')
			assert page.has_css?('div#page')
#			page.execute_script("$('div#page').remove()")
#			assert page.has_no_css?('div#page')
#puts current_path - finally current_path ( webrat doesn't have this method )
#puts current_url
flunk
		end

	end

end
