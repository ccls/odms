require 'integration_test_helper'

class PatientJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#	edit_patient.js
#
#var initial_admit_date;
#function admit_date(){
#	return jQuery('#patient_admit_date').val();
#}
#function admit_date_changed(){
#	return initial_admit_date != admit_date();
#}
#jQuery(function(){
#
#	initial_admit_date = admit_date();
#	
#	jQuery('#patient_admit_date').change(function(){
#		if( admit_date_changed() ) {
#			$(this).parent().parent().addClass('changed');
#		} else {
#			$(this).parent().parent().removeClass('changed');
#		}
#	});
#
#	jQuery('#patient_diagnosis_id').smartShow({
#		what: 'form.edit_patient div.other_diagnosis',
#		when: function(){ 
#			return /Other/i.test( 
#				$('#patient_diagnosis_id option:selected').text() )
#		}
#	});
#
#});
#
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
#
	end

end
