require 'integration_test_helper'

class PhoneNumberIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

#	phone_number#new
#
#		test "phone_number#new should show why_invalid when is_valid is changed to" <<
#				" 'No' with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as send(cu)
#			visit new_study_subject_phone_number_path(study_subject)
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "No", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#			select "", :from => 'phone_number[is_valid]'
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "No", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#		end
#
#		test "phone_number#new should show why_invalid when is_valid is changed to" <<
#				" 'Don't Know' with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as send(cu)
#			visit new_study_subject_phone_number_path(study_subject)
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "Don't Know", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#			select "", :from => 'phone_number[is_valid]'
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "Don't Know", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#		end
#
#		test "phone_number#new should show how_verified when is_verified is checked" <<
#				" with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as send(cu)
#			visit new_study_subject_phone_number_path(study_subject)
#			assert !find_field('phone_number[how_verified]').visible?
#			check 'phone_number[is_verified]'
#			assert find_field('phone_number[how_verified]').visible?
#			uncheck 'phone_number[is_verified]'
#			assert !find_field('phone_number[how_verified]').visible?
#			check 'phone_number[is_verified]'
#			assert find_field('phone_number[how_verified]').visible?
#		end

		test "phone_number#new should show other_data_source when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_phone_number_path(study_subject)
			assert !find_field('phone_number[other_data_source]').visible?
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert find_field('phone_number[other_data_source]').visible?
			select "", :from => 'phone_number[data_source_id]'
			assert !find_field('phone_number[other_data_source]').visible?
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert find_field('phone_number[other_data_source]').visible?
		end

#	phone_number#edit

#		test "phone_number#edit should show why_invalid when is_valid is changed to" <<
#				" 'No' with #{cu} login" do
#			phone_number = FactoryGirl.create(:phone_number)
#			login_as send(cu)
#			visit edit_study_subject_phone_number_path(phone_number.study_subject,phone_number)
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "No", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#			select "", :from => 'phone_number[is_valid]'
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "No", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#		end
#
#		test "phone_number#edit should show why_invalid when is_valid is changed to" <<
#				" 'Don't Know' with #{cu} login" do
#			phone_number = FactoryGirl.create(:phone_number)
#			login_as send(cu)
#			visit edit_study_subject_phone_number_path(phone_number.study_subject,phone_number)
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "Don't Know", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#			select "", :from => 'phone_number[is_valid]'
#			assert !find_field('phone_number[why_invalid]').visible?
#			select "Don't Know", :from => 'phone_number[is_valid]'
#			assert find_field('phone_number[why_invalid]').visible?
#		end
#
#		test "phone_number#edit should show how_verified when is_verified is checked" <<
#				" with #{cu} login" do
#			phone_number = FactoryGirl.create(:phone_number)
#			login_as send(cu)
#			visit edit_study_subject_phone_number_path(phone_number.study_subject,phone_number)
#			assert !find_field('phone_number[how_verified]').visible?
#			check 'phone_number[is_verified]'
#			assert find_field('phone_number[how_verified]').visible?
#			uncheck 'phone_number[is_verified]'
#			assert !find_field('phone_number[how_verified]').visible?
#			check 'phone_number[is_verified]'
#			assert find_field('phone_number[how_verified]').visible?
#		end

		test "phone_number#edit should show other_data_source when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			visit edit_study_subject_phone_number_path(phone_number.study_subject,phone_number)
			assert !find_field('phone_number[other_data_source]').visible?
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert find_field('phone_number[other_data_source]').visible?
			select "", :from => 'phone_number[data_source_id]'
			assert !find_field('phone_number[other_data_source]').visible?
			select "Other Source", :from => 'phone_number[data_source_id]'
			assert find_field('phone_number[other_data_source]').visible?
		end

	end

end
