require 'integration_test_helper'

class PageIntegrationTest < ActionController::CapybaraIntegrationTest

	test "should get home page if not logged in" do
		visit root_path()
		assert !page.has_css?("p.flash#error")
		assert_equal root_path, current_path
	end

	site_editors.each do |cu|

		test "should create new page with #{cu} login" do
			login_as send(cu)
			visit new_page_path
			fill_in "page[path]",     :with => "/MyNewPath"
			fill_in "page[menu_en]",  :with => "MyNewMenu"
			fill_in "page[title_en]", :with => "MyNewTitle"
			fill_in "page[body_en]",  :with => "MyNewBody"



#	I don't understand why capybara doesn't work here
#			assert_difference('Page.count',1) {	#	TODO doesn't seem to work in capybara? basic db and not shared db??
				click_button "Create"	
#			}



			assert page.has_css?("p.flash#notice")	#	success
		end

		test "should edit a page with #{cu} login" do
			assert Page.count > 0
			p = Page.first	#	DO NOT USE page as it is part of capybara
			login_as send(cu)
			visit edit_page_path(p)
			assert_equal edit_page_path(p), current_path
		end

		test "should edit and update a page with #{cu} login" do
			assert Page.count > 0
			p = Page.first	#	DO NOT USE page as it is part of capybara
			login_as send(cu)
			visit edit_page_path(p)
			fill_in "page[menu_en]", :with => "MyNewMenu"
			click_button "Update"	
			assert page.has_css?("p.flash#notice")
			assert_equal current_path, page_path(p)
		end

	end

end
