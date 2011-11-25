require 'integration_test_helper'

class StudySubjectIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#	phone_number#edit
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
#	edit_study_subject.js
#
#
#jQuery(function(){
#
#	jQuery('form.edit_study_subject input:checkbox.is_primary_selector').click(function(){
#		/* if primary is checked, 
#				check partial race as well as uncheck other primary
#		*/
#		if( jQuery(this).attr('checked') ){
#			var id = jQuery(this).attr('id').replace(/_is_primary/,'');
#			jQuery('#'+id).attr('checked',true);
#
#			/* easier to uncheck all, then recheck this one */
#			jQuery('form.edit_study_subject input:checkbox.is_primary_selector').attr('checked',false);
#			jQuery(this).attr('checked',true);
#		}
#	});
#
#	jQuery('form.edit_study_subject input:checkbox.race_selector').click(function(){
#		/* if race unchecked, uncheck is_primary too */
#		if( !jQuery(this).attr('checked') ){
#			jQuery('#'+jQuery(this).attr('id')+'_is_primary').attr('checked',false);
#		}
#	});
#
#});
#
	end

end
