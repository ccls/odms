require 'integration_test_helper'

class PhoneNumberJavascriptIntegrationTest < ActionController::CapybaraIntegrationTest

#	has_field? ignores visibility and the :visible option!!!!!
#		use find_field and visible? for form field names
#		ie. use this ...
#			assert !page.find_field("study_subject[subject_languages_attributes][2][other]").visible?	#	specify other hidden
#		and not ...
#			assert page.has_field?("study_subject[subject_languages_attributes][2][other]", :visible => false)	#	specify other hidden
#		as the latter will be true if the field is there regardless of if it is visible

	site_administrators.each do |cu|

#	phone_number#new






#	phone_number#edit

		test "phone_number#edit should show why_invalid when is_valid is changed to" <<
				" 'No' with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert !page.find_field('phone_number[why_invalid]').visible?
			select "No", :from => 'phone_number[is_valid]'
			assert page.find_field('phone_number[why_invalid]').visible?
			select "", :from => 'phone_number[is_valid]'
			assert !page.find_field('phone_number[why_invalid]').visible?
			select "No", :from => 'phone_number[is_valid]'
			assert page.find_field('phone_number[why_invalid]').visible?
		end

		test "phone_number#edit should show why_invalid when is_valid is changed to" <<
				" 'Don't Know' with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert !page.find_field('phone_number[why_invalid]').visible?
			select "Don't Know", :from => 'phone_number[is_valid]'
			assert page.find_field('phone_number[why_invalid]').visible?
			select "", :from => 'phone_number[is_valid]'
			assert !page.find_field('phone_number[why_invalid]').visible?
			select "Don't Know", :from => 'phone_number[is_valid]'
			assert page.find_field('phone_number[why_invalid]').visible?
		end

		test "phone_number#edit should show how_verified when is_verified is checked" <<
				" with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert !page.find_field('phone_number[how_verified]').visible?
			check 'phone_number[is_verified]'
			assert page.find_field('phone_number[how_verified]').visible?
			uncheck 'phone_number[is_verified]'
			assert !page.find_field('phone_number[how_verified]').visible?
			check 'phone_number[is_verified]'
			assert page.find_field('phone_number[how_verified]').visible?
		end

		test "phone_number#edit should show data_source_other when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			phone_number = Factory(:phone_number)
			login_as send(cu)
			page.visit edit_phone_number_path(phone_number)
			assert !page.find_field('phone_number[data_source_other]').visible?
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert page.find_field('phone_number[data_source_other]').visible?
			select "", :from => 'phone_number[data_source_id]'
			assert !page.find_field('phone_number[data_source_other]').visible?
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert page.find_field('phone_number[data_source_other]').visible?
		end

	end

end
