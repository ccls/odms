require 'webrat_integration_test_helper'
#require 'capybara_integration_test_helper'

#class PageIntegrationTest < ActionController::IntegrationTest
class PageIntegrationTest < ActionController::WebRatIntegrationTest

	test "should get home page if not logged in" do
		get root_path(), {}, { 'HTTPS' => 'on' }
		assert_nil flash[:error]
		assert_response :success
	end

	site_administrators.each do |cu|

		test "should create new page with #{cu} login" do
			login_as send(cu)

			visit new_page_path
#
#			page.driver.get new_page_path(), {}, { 'HTTPS' => 'on' }
#
#
#	added ... to capybara-1.1.2/lib/capybara/rack_test/browser.rb
#		to force usage of SSL.  Should find a better way.
#
#	117     env.merge!(options[:headers]) if options[:headers]
#	118 env.merge!( { 'HTTPS' => 'on' })
#	119 puts env.inspect
#	120     env
#	121   end
#
#	but can't seem to get capybara to recognize that the user has permission to maintain pages.
#
#puts page.body
			fill_in "page[path]",     :with => "/MyNewPath"
			fill_in "page[menu_en]",  :with => "MyNewMenu"
			fill_in "page[title_en]", :with => "MyNewTitle"
			fill_in "page[body_en]",  :with => "MyNewBody"

			assert_difference('Page.count',1) {
				#	click_button(value)
				click_button "Create"	
			}
#flunk
		end

		test "should edit a page with #{cu} login" do
			assert Page.count > 0
			page = Page.first
			login_as send(cu)
			get edit_page_path(page), {}, { 'HTTPS' => 'on' }
			assert_response :success
		end

		test "should edit and update a page with #{cu} login" do
			assert Page.count > 0
			page = Page.first
			login_as send(cu)

			visit edit_page_path(page)
			fill_in "page[menu_en]", :with => "MyNewMenu"

			#	click_button(value)
			click_button "Update"	

			assert_not_nil flash[:notice]
			assert_response :success
		end

	end

end
