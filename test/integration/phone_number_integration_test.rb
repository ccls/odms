require 'integration_test_helper'

class PhoneNumberIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#	phone_number#edit

		test "phone_number#edit should show why_invalid when is_valid is changed to 'No' with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert page.has_field?('phone_number[why_invalid]', :visible => false)
			select "No", :from => 'phone_number[is_valid]'
			assert page.has_field?('phone_number[why_invalid]', :visible => true)
			select "", :from => 'phone_number[is_valid]'
			assert page.has_field?('phone_number[why_invalid]', :visible => false)
			select "No", :from => 'phone_number[is_valid]'
			assert page.has_field?('phone_number[why_invalid]', :visible => true)
		end

		test "phone_number#edit should show why_invalid when is_valid is changed to 'Don't Know' with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert page.has_field?('phone_number[why_invalid]', :visible => false)
			select "Don't Know", :from => 'phone_number[is_valid]'
			assert page.has_field?('phone_number[why_invalid]', :visible => true)
			select "", :from => 'phone_number[is_valid]'
			assert page.has_field?('phone_number[why_invalid]', :visible => false)
			select "Don't Know", :from => 'phone_number[is_valid]'
			assert page.has_field?('phone_number[why_invalid]', :visible => true)
		end

		test "phone_number#edit should show how_verified when is_verified is checked with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert page.has_field?('phone_number[how_verified]', :visible => false)
			check 'phone_number[is_verified]'
			assert page.has_field?('phone_number[how_verified]', :visible => true)
			uncheck 'phone_number[is_verified]'
			assert page.has_field?('phone_number[how_verified]', :visible => false)
			check 'phone_number[is_verified]'
			assert page.has_field?('phone_number[how_verified]', :visible => true)
		end

		test "phone_number#edit should show data_source_other when 'Other Source' data_source is selected with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert page.has_field?('phone_number[data_source_other]', :visible => false)
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert page.has_field?('phone_number[data_source_other]', :visible => true)
			select "", :from => 'phone_number[data_source_id]'
			assert page.has_field?('phone_number[data_source_other]', :visible => false)
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert page.has_field?('phone_number[data_source_other]', :visible => true)
		end

##	raf.js
##
##
##
##jQuery(function(){
##
##	var root = /(ccls|genepi.).berkeley.edu/.test(location.host)?'/odms':''
##
##	jQuery('#study_subject_patient_attributes_raf_zip').change(function(){
##		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
##			if(data.length == 1) {
##				update_address_info(data[0].zip_code);
##			}
##		});
##	});
##
##	jQuery('#study_subject_addressings_attributes_0_address_attributes_zip').change(function(){
##		jQuery.get(root + '/zip_codes.json?q=' + jQuery(this).val(), function(data){
##			if(data.length == 1) {
##				update_address_info(data[0].zip_code);
##			}
##		});
##	});
##
##	jQuery('#study_subject_patient_attributes_diagnosis_id').smartShow({
##		what: 'form.raf div.other_diagnosis',
##		when: function(){ 
##			return /Other/i.test( 
##				$('#study_subject_patient_attributes_diagnosis_id option:selected').text() )
##		}
##	});
##
##});
##
##var update_address_info = function(zip_code) {
##/*
##	[{"zip_code":{"county_name":"Schenectady","city":"SCHENECTADY","zip_code":"12345","state":"NY"}}]
##*/
##/* only copy in the values if the target is empty */
##	var address_zip = jQuery('#study_subject_addressings_attributes_0_address_attributes_zip');
##	if( address_zip && !address_zip.val() ){
##		address_zip.val(zip_code.zip_code);
##	}
##	var address_county = jQuery('#study_subject_addressings_attributes_0_address_attributes_county');
##	if( address_county && !address_county.val() ){
##		address_county.val(zip_code.county_name);
##	}
##	var address_city = jQuery('#study_subject_addressings_attributes_0_address_attributes_city');
##	if( address_city && !address_city.val() ){
##		address_city.val(zip_code.city);
##	}
##	var address_state = jQuery('#study_subject_addressings_attributes_0_address_attributes_state');
##	if( address_state && !address_state.val() ){
##		address_state.val(zip_code.state);
##	}
##	var raf_zip = jQuery('#study_subject_patient_attributes_raf_zip');
##	if( raf_zip && !raf_zip.val() ){
##		raf_zip.val(zip_code.zip_code);
##	}
##	var raf_county = jQuery('#study_subject_patient_attributes_raf_county');
##	if( raf_county && !raf_county.val() ){
##		raf_county.val(zip_code.county_name);
##	}
##}
##
#
#
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
