require 'integration_test_helper'

class ConsentJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

#	consent#edit (shouldn't have a consent#new)

#	jQuery('a.toggle_eligibility_criteria').togglerFor('.eligibility_criteria');
#	jQuery('#enrollment_is_eligible').smartShow({
#		what: '.ineligible_reason_id.field_wrapper',
#		when: function(){ 
#			return /no/i.test( 
#				$('#enrollment_is_eligible option:selected').text() ) }
#	});
#
#	jQuery('#enrollment_ineligible_reason_id').smartShow({
#		what: '.ineligible_reason_specify.field_wrapper',
#		when: function(){ 
#			return /other/i.test( 
#				$('#enrollment_ineligible_reason_id option:selected').text() ) }
#	});
#
#/*
#	need consented on if consent is Yes or No
#*/
#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_consented',
#		when: function(){ 
#			return /^(yes|no)/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
#
#/*
#	need refusal reason if consent is No
#*/
#	jQuery('#enrollment_consented').smartShow({
#		what: '#subject_refused',
#		when: function(){ 
#			return /^no/i.test( 
#				$('#enrollment_consented option:selected').text() ) }
#	});
#
#	jQuery('#enrollment_refusal_reason_id').smartShow({
#		what: '.other_refusal_reason.field_wrapper',
#		when: function(){ 
#			return /other/i.test( 
#				$('#enrollment_refusal_reason_id option:selected').text() ) }
#	});
#
#
#
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

	end

end
