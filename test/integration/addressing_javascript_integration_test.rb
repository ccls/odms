require 'integration_test_helper'

class AddressingJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

		test "addressing#edit should update blank city, state and county on zip code change with #{cu} login" do
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

#	don't know if there is a difference between fill_in and page.fill_in.
			fill_in "addressing[address_attributes][zip]",  :with => "17857"

#
#	sometimes this happens too fast? This may happen as the browser
#	actually exists and perhaps me coding while the browser is trying to
#	test takes focus away from it?  Can I force the browser into the background?
#
#			sleep 1
#
#	sometimes this works, sometimes it doesn't ???
#
#	perhaps be more explicit? kinda defeats the purpose of the test.
			#	maybe "change" isn't the appropriate event trigger for this?
			page.execute_script("$('#addressing_address_attributes_zip').change()" );

#			fill_in "addressing[address_attributes][line_2]",  
#				:with => "something to trigger zip code change event"
			sleep 1


#	Basically do something to move away from the zip field.
#	This then triggers the 'change' event a second time.
#	The 'fill_in' apparently does trigger the event, but the value is blank?
#	I don't quite understand this, and I don't really like it.
#	Nevertheless, it works. Sometimes.
#
#Processing ZipCodesController#index to json (for 127.0.0.1 at 2011-11-28 13:09:49) [GET]
#  Parameters: {"q"=>""}
#  ZipCode Load (0.5ms)   SELECT city, state, zip_code, county_id, counties.name as county_name FROM `zip_codes` LEFT JOIN counties ON zip_codes.county_id = counties.id WHERE (zip_code LIKE '%') ORDER BY zip_code LIMIT 10
#Completed in 9ms (View: 5, DB: 0) | 200 OK [http://127.0.0.1/zip_codes.json?q=]
#
#
#Processing ZipCodesController#index to json (for 127.0.0.1 at 2011-11-28 13:09:49) [GET]
#  Parameters: {"q"=>"17857"}
#  ZipCode Load (0.3ms)   SELECT city, state, zip_code, county_id, counties.name as county_name FROM `zip_codes` LEFT JOIN counties ON zip_codes.county_id = counties.id WHERE (zip_code LIKE '17857%') ORDER BY zip_code LIMIT 10
#Completed in 3ms (View: 1, DB: 0) | 200 OK [http://127.0.0.1/zip_codes.json?q=17857]
#

			assert_equal 'NORTHUMBERLAND',
				page.find_field("addressing[address_attributes][city]").value
			assert_equal 'Northumberland',
				page.find_field("addressing[address_attributes][county]").value
			assert_equal 'PA',
				page.find_field("addressing[address_attributes][state]").value
			assert_equal '17857',
				page.find_field("addressing[address_attributes][zip]").value
		end

		test "addressing#edit should show why_invalid when is_valid is changed to 'No' with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert page.has_field?('addressing[why_invalid]', :visible => false)
			select "No", :from => 'addressing[is_valid]'
			assert page.has_field?('addressing[why_invalid]', :visible => true)
			select "", :from => 'addressing[is_valid]'
			assert page.has_field?('addressing[why_invalid]', :visible => false)
			select "No", :from => 'addressing[is_valid]'
			assert page.has_field?('addressing[why_invalid]', :visible => true)
		end

		test "addressing#edit should show why_invalid when is_valid is changed to 'Don't Know' with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert page.has_field?('addressing[why_invalid]', :visible => false)
			select "Don't Know", :from => 'addressing[is_valid]'
			assert page.has_field?('addressing[why_invalid]', :visible => true)
			select "", :from => 'addressing[is_valid]'
			assert page.has_field?('addressing[why_invalid]', :visible => false)
			select "Don't Know", :from => 'addressing[is_valid]'
			assert page.has_field?('addressing[why_invalid]', :visible => true)
		end

		test "addressing#edit should show how_verified when is_verified is checked with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert page.has_field?('addressing[how_verified]', :visible => false)
			check 'addressing[is_verified]'
			assert page.has_field?('addressing[how_verified]', :visible => true)
			uncheck 'addressing[is_verified]'
			assert page.has_field?('addressing[how_verified]', :visible => false)
			check 'addressing[is_verified]'
			assert page.has_field?('addressing[how_verified]', :visible => true)
		end

		test "addressing#edit should show data_source_other when 'Other Source' data_source is selected with #{cu} login" do
			addressing = Factory(:addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert page.has_field?('addressing[data_source_other]', :visible => false)
			select "Other Source", :from => 'addressing[data_source_id]'
			assert page.has_field?('addressing[data_source_other]', :visible => true)
			select "", :from => 'addressing[data_source_id]'
			assert page.has_field?('addressing[data_source_other]', :visible => false)
			select "Other Source", :from => 'addressing[data_source_id]'
			assert page.has_field?('addressing[data_source_other]', :visible => true)
		end

		test "addressing#edit should show subject_moved when residence address current_address is changed to 'No' with #{cu} login" do
			addressing = Factory(:current_residence_addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert page.has_field?('addressing[subject_moved]', :visible => false)
			select "No", :from => 'addressing[current_address]'
			assert page.has_field?('addressing[subject_moved]', :visible => true)
			select "", :from => 'addressing[current_address]'
			assert page.has_field?('addressing[subject_moved]', :visible => false)
			select "No", :from => 'addressing[current_address]'
			assert page.has_field?('addressing[subject_moved]', :visible => true)
		end

		test "addressing#edit should NOT show subject_moved when residence address current_address is changed to 'Don't Know' with #{cu} login" do
			addressing = Factory(:current_residence_addressing)
			login_as send(cu)
			page.visit edit_addressing_path(addressing)
			assert page.has_field?('addressing[subject_moved]', :visible => false)
			select "Don't Know", :from => 'addressing[current_address]'
			assert page.has_field?('addressing[subject_moved]', :visible => false)
			select "", :from => 'addressing[current_address]'
			assert page.has_field?('addressing[subject_moved]', :visible => false)
			select "Don't Know", :from => 'addressing[current_address]'
			assert page.has_field?('addressing[subject_moved]', :visible => false)
		end

#	addressing#new

		test "addressing#new should show confirm when new residence addressing is submitted with state not 'CA' and #{cu} login" do
#			login_as send(cu)
pending
#jQuery(function(){
#
#	jQuery('form#new_addressing').submit(state_check);
#
#});
#
#var state_check = function() {
#	var state = jQuery('#addressing_address_attributes_state').val()
#	var type  = jQuery('#addressing_address_attributes_address_type_id').val()
#	if( ( state != 'CA' ) && ( type == '1' ) &&
#		( !confirm('This address is not in CA and will make study_subject ineligible.  Do you want to continue?') ) ) {
#		return false;
#	}
#}
#
		end

		test "addressing#new should update blank city, state and county on zip code change with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			page.visit new_study_subject_addressing_path(study_subject)
			assert page.find_field("addressing[address_attributes][city]").value.blank?
			assert page.find_field("addressing[address_attributes][county]").value.blank?
			assert page.find_field("addressing[address_attributes][state]").value.blank?
			assert page.find_field("addressing[address_attributes][zip]").value.blank?

			fill_in "addressing[address_attributes][zip]",  :with => "17857"

#
#	sometimes this happens too fast?
#
#			sleep 1
#
#	sometimes this works, sometimes it doesn't ???
#
#			fill_in "addressing[address_attributes][line_2]",  
#				:with => "something to trigger zip code change event"
			#	maybe "change" isn't the appropriate event trigger for this?
			page.execute_script("$('#addressing_address_attributes_zip').change()" );
			sleep 1


#	Basically do something to move away from the zip field.
#	This then triggers the 'change' event a second time.
#	The 'fill_in' apparently does trigger the event, but the value is blank?
#	I don't quite understand this, and I don't really like it.
#	Nevertheless, it works. Sometimes.
#
#Processing ZipCodesController#index to json (for 127.0.0.1 at 2011-11-28 13:09:49) [GET]
#  Parameters: {"q"=>""}
#  ZipCode Load (0.5ms)   SELECT city, state, zip_code, county_id, counties.name as county_name FROM `zip_codes` LEFT JOIN counties ON zip_codes.county_id = counties.id WHERE (zip_code LIKE '%') ORDER BY zip_code LIMIT 10
#Completed in 9ms (View: 5, DB: 0) | 200 OK [http://127.0.0.1/zip_codes.json?q=]
#
#
#Processing ZipCodesController#index to json (for 127.0.0.1 at 2011-11-28 13:09:49) [GET]
#  Parameters: {"q"=>"17857"}
#  ZipCode Load (0.3ms)   SELECT city, state, zip_code, county_id, counties.name as county_name FROM `zip_codes` LEFT JOIN counties ON zip_codes.county_id = counties.id WHERE (zip_code LIKE '17857%') ORDER BY zip_code LIMIT 10
#Completed in 3ms (View: 1, DB: 0) | 200 OK [http://127.0.0.1/zip_codes.json?q=17857]
#

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
