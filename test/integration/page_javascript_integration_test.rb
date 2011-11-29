require 'integration_test_helper'

class PageJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

##	phone_number#edit
#
#		test "phone_number#edit should show why_invalid when is_valid is changed to 'No' with #{cu} login" do
#			phone_number = Factory(:phone_number)
#			login_as send(cu)
#			page.visit edit_phone_number_path(phone_number)
#			assert page.has_field?('phone_number[why_invalid]', :visible => false)
#			select "No", :from => 'phone_number[is_valid]'
#			assert page.has_field?('phone_number[why_invalid]', :visible => true)
#			select "", :from => 'phone_number[is_valid]'
#			assert page.has_field?('phone_number[why_invalid]', :visible => false)
#			select "No", :from => 'phone_number[is_valid]'
#			assert page.has_field?('phone_number[why_invalid]', :visible => true)
#		end
#
#		test "phone_number#edit should show why_invalid when is_valid is changed to 'Don't Know' with #{cu} login" do
#			phone_number = Factory(:phone_number)
#			login_as send(cu)
#			page.visit edit_phone_number_path(phone_number)
#			assert page.has_field?('phone_number[why_invalid]', :visible => false)
#			select "Don't Know", :from => 'phone_number[is_valid]'
#			assert page.has_field?('phone_number[why_invalid]', :visible => true)
#			select "", :from => 'phone_number[is_valid]'
#			assert page.has_field?('phone_number[why_invalid]', :visible => false)
#			select "Don't Know", :from => 'phone_number[is_valid]'
#			assert page.has_field?('phone_number[why_invalid]', :visible => true)
#		end
#
#		test "phone_number#edit should show how_verified when is_verified is checked with #{cu} login" do
#			phone_number = Factory(:phone_number)
#			login_as send(cu)
#			page.visit edit_phone_number_path(phone_number)
#			assert page.has_field?('phone_number[how_verified]', :visible => false)
#			check 'phone_number[is_verified]'
#			assert page.has_field?('phone_number[how_verified]', :visible => true)
#			uncheck 'phone_number[is_verified]'
#			assert page.has_field?('phone_number[how_verified]', :visible => false)
#			check 'phone_number[is_verified]'
#			assert page.has_field?('phone_number[how_verified]', :visible => true)
#		end
#
#		test "phone_number#edit should show data_source_other when 'Other Source' data_source is selected with #{cu} login" do
#			phone_number = Factory(:phone_number)
#			login_as send(cu)
#			page.visit edit_phone_number_path(phone_number)
#			assert page.has_field?('phone_number[data_source_other]', :visible => false)
#			select "Other Source", :from => 'phone_number[data_source_id]'
#			assert page.has_field?('phone_number[data_source_other]', :visible => true)
#			select "", :from => 'phone_number[data_source_id]'
#			assert page.has_field?('phone_number[data_source_other]', :visible => false)
#			select "Other Source", :from => 'phone_number[data_source_id]'
#			assert page.has_field?('phone_number[data_source_other]', :visible => true)
#		end
#
##
##	pages.js
##
##
##
##var initial_page_order;
##jQuery(function(){
##	jQuery('#pages').sortable({
##		axis:'y', 
##		dropOnEmpty:false, 
##		handle:'img.handle', 
##		update:function(event,ui){compare_page_order()},
##		items:'tr.page.row'
##	});
##
##	jQuery('#save_order').disable();
##
##	initial_page_order = page_order();
##
##	jQuery('form#order_pages').submit(function(){
##		if( initial_page_order == page_order() ) {
##			/*
##				Shouldn't get here as button should 
##				be disabled if not different!
##			*/
##			alert("Page order hasn't changed. Nothing to save.");
##			return false
##		} else {
##			new_action = jQuery(this).attr('action');
##			if( (/\?/).test(new_action) ){
##				new_action += '&';
##			} else {
##				new_action += '?';
##			}
##			new_action += page_order();
##			jQuery(this).attr('action',new_action);
##		}
##	})
##
##});
##
##function page_order() {
##	return jQuery('#pages').sortable('serialize',{key:'pages[]'});
##}
##
##function compare_page_order(){
##	if( initial_page_order == page_order() ) {
##		jQuery('#save_order').disable();
##	} else {
##		jQuery('#save_order').highlight(4000);
##		jQuery('#save_order').enable();
##	}
##}
##
#
#
##	application.js
##	common_lib.js
#
#
#		#	this was just a basic functionality test
#		test "should create new page with #{cu} login" do
##			login_as send(cu)
##			page.visit new_page_path
##
##			fill_in "page[path]",     :with => "/MyNewPath"
##			fill_in "page[menu_en]",  :with => "MyNewMenu"
##			fill_in "page[title_en]", :with => "MyNewTitle"
##			fill_in "page[body_en]",  :with => "MyNewBody"
##
##			assert_difference('Page.count',1) {
##				#	click_button(value)
##				#				page.click_button "Create"	
##				#	As this is one of my submit_link_tos, ...
##				#	Selenium::WebDriver::Error::ElementNotDisplayedError: Element is not currently visible and so may not be interacted with
##				page.click_link "Create"	
##			}
##			assert page.has_no_css?('div#somethingthatdoesnotexist')
##			assert page.has_css?('div#page')
##
##			page.execute_script("$('div#page').remove()")
##			assert page.has_no_css?('div#page')
##
##				#puts current_path - finally current_path ( webrat doesn't have this method )
##				#puts current_url
##				#flunk
#		end

	end

end
