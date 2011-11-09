require 'integration_test_helper'

class PageIntegrationTest < ActionController::IntegrationTest

	test "should get home page if not logged in" do
		get root_path(), {}, { 'HTTPS' => 'on' }
		assert_nil flash[:error]
		assert_response :success
	end

	site_administrators.each do |cu|

		test "should create new page with #{cu} login using webrat" do
			login_as send(cu)
			#	need to set HTTPS for webrat
			header('HTTPS', 'on')
			visit new_page_path
			fill_in "page[path]",     :with => "/MyNewPath"
			fill_in "page[menu_en]",  :with => "MyNewMenu"
			fill_in "page[title_en]", :with => "MyNewTitle"
			fill_in "page[body_en]",  :with => "MyNewBody"

			assert_difference('Page.count',1) {
				#	click_button(value)
				click_button "Create"	
			}
		end

		test "should edit a page with #{cu} login" do
			assert Page.count > 0
			page = Page.first
			login_as send(cu)
			get edit_page_path(page), {}, { 'HTTPS' => 'on' }
			assert_response :success
		end

		test "should edit and update a page with #{cu} login using webrat" do
			assert Page.count > 0
			page = Page.first
			login_as send(cu)

			#	need to set HTTPS for webrat
			header('HTTPS', 'on')
			visit edit_page_path(page)
			fill_in "page[menu_en]", :with => "MyNewMenu"

			#	click_button(value)
			click_button "Update"	

			assert_not_nil flash[:notice]
			assert_response :success
		end

	end

end
