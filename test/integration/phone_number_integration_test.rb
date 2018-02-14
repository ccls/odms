require 'integration_test_helper'

class PhoneNumberIntegrationTest < ActionDispatch::CapybaraIntegrationTest

	site_editors.each do |cu|

#	phone_number#new

		test "phone_number#new should show other_data_source when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_phone_number_path(study_subject)
			assert !( find_field('phone_number[other_data_source]', :visible => false).visible? )
			select "Other Source", :from => 'phone_number[data_source]'
			assert find_field('phone_number[other_data_source]').visible?
			select "", :from => 'phone_number[data_source]'
			assert !( find_field('phone_number[other_data_source]', :visible => false).visible? )
			select "Other Source", :from => 'phone_number[data_source]'
			assert find_field('phone_number[other_data_source]').visible?
		end

#	phone_number#edit

	test "phone_number#edit should show other_data_source when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			phone_number = FactoryBot.create(:phone_number)
			login_as send(cu)
			visit edit_study_subject_phone_number_path(phone_number.study_subject,phone_number)
			assert !( find_field('phone_number[other_data_source]', :visible => false).visible? )
			select "Other Source", :from => 'phone_number[data_source]'
			assert find_field('phone_number[other_data_source]').visible?
			select "", :from => 'phone_number[data_source]'
			assert !( find_field('phone_number[other_data_source]', :visible => false).visible? )
			select "Other Source", :from => 'phone_number[data_source]'
			assert find_field('phone_number[other_data_source]').visible?
		end

	end

end


#	find_field takes a has like has_css? now?

#		 visible (Boolean) — Only find elements that are visible on the page. Setting this to false finds invisible and visible elements.
#
#	:visible => false does NOT mean invisible.  It means pay no attention to whether its visible.

