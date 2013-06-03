require 'integration_test_helper'

class AddressingIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "addressing#edit should update blank address info on zip code change" <<
				" with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
			fill_in "addressing[address_attributes][city]",  :with => ""
			fill_in "addressing[address_attributes][county]",  :with => ""
			select "", :from => 'addressing[address_attributes][state]'
			fill_in "addressing[address_attributes][zip]",  :with => ""
			assert find_field("addressing[address_attributes][city]").value.blank?
			assert find_field("addressing[address_attributes][county]").value.blank?
			assert find_field("addressing[address_attributes][state]").value.blank?
			assert find_field("addressing[address_attributes][zip]").value.blank?

			fill_in "addressing[address_attributes][zip]",  :with => "17857"

#wait_until{ !find_field("addressing[address_attributes][city]").value.blank? }
wait_until{ find_field("addressing[address_attributes][city]").value.present? }

			assert_equal 'Northumberland',
				find_field("addressing[address_attributes][city]").value
			assert_equal 'Northumberland',
				find_field("addressing[address_attributes][county]").value
			assert_equal 'PA',
				find_field("addressing[address_attributes][state]").value
			assert_equal '17857',
				find_field("addressing[address_attributes][zip]").value
		end

#		test "addressing#edit should show why_invalid when is_valid is changed to 'No'" <<
#				" with #{cu} login" do
#			addressing = FactoryGirl.create(:addressing)
#			login_as send(cu)
#			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
#			assert !find_field('addressing[why_invalid]').visible?
#			select "No", :from => 'addressing[is_valid]'
#			assert find_field('addressing[why_invalid]').visible?
#			select "", :from => 'addressing[is_valid]'
#			assert !find_field('addressing[why_invalid]').visible?
#			select "No", :from => 'addressing[is_valid]'
#			assert find_field('addressing[why_invalid]').visible?
#		end
#
#		test "addressing#edit should show why_invalid when is_valid is changed to" <<
#				" 'Don't Know' with #{cu} login" do
#			addressing = FactoryGirl.create(:addressing)
#			login_as send(cu)
#			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
#			assert !find_field('addressing[why_invalid]').visible?
#			select "Don't Know", :from => 'addressing[is_valid]'
#			assert find_field('addressing[why_invalid]').visible?
#			select "", :from => 'addressing[is_valid]'
#			assert !find_field('addressing[why_invalid]').visible?
#			select "Don't Know", :from => 'addressing[is_valid]'
#			assert find_field('addressing[why_invalid]').visible?
#		end
#
#		test "addressing#edit should show how_verified when is_verified is checked" <<
#				" with #{cu} login" do
#			addressing = FactoryGirl.create(:addressing)
#			login_as send(cu)
#			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
#			assert !find_field('addressing[how_verified]').visible?
#			check 'addressing[is_verified]'
#			assert find_field('addressing[how_verified]').visible?
#			uncheck 'addressing[is_verified]'
#			assert !find_field('addressing[how_verified]').visible?
#			check 'addressing[is_verified]'
#			assert find_field('addressing[how_verified]').visible?
#		end

		test "addressing#edit should show other_data_source when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
			assert !find_field('addressing[other_data_source]').visible?
			select "Other Source", :from => 'addressing[data_source_id]'
			assert find_field('addressing[other_data_source]').visible?
			select "", :from => 'addressing[data_source_id]'
			assert !find_field('addressing[other_data_source]').visible?
			select "Other Source", :from => 'addressing[data_source_id]'
			assert find_field('addressing[other_data_source]').visible?
		end

		test "addressing#edit should show subject_moved when residence address" <<
				" current_address is changed to 'No' with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
			assert !find_field('addressing[subject_moved]').visible?
			select "No", :from => 'addressing[current_address]'
			assert find_field('addressing[subject_moved]').visible?
			select "", :from => 'addressing[current_address]'
			assert !find_field('addressing[subject_moved]').visible?
			select "No", :from => 'addressing[current_address]'
			assert find_field('addressing[subject_moved]').visible?
		end

		test "addressing#edit should NOT show subject_moved when residence address" <<
				" current_address is changed to 'Don't Know' with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			visit edit_study_subject_addressing_path(addressing.study_subject,addressing)
			assert !find_field('addressing[subject_moved]').visible?
			select "Don't Know", :from => 'addressing[current_address]'
			assert !find_field('addressing[subject_moved]').visible?
			select "", :from => 'addressing[current_address]'
			assert !find_field('addressing[subject_moved]').visible?
			select "Don't Know", :from => 'addressing[current_address]'
			assert !find_field('addressing[subject_moved]').visible?
		end

#	addressing#new

		test "addressing#new should show confirm when new residence addressing is" <<
				" submitted with state not 'CA' and #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_addressing_path(study_subject)
			#	residence address and NOT in 'CA'
			select 'PA', :from => "addressing[address_attributes][state]"
			select 'residence', :from => "addressing[address_attributes][address_type_id]"

			#	we don't want to actually save, so cancel with ....
			evaluate_script('window.confirm = function() { return false; }')

			click_button 'Save'

			#	Without overriding the confirm function, clicking save will submit
			#		and the current_path would be /study_subjects/:id/addressings
			#	When confirm returns false, it will stay at same path.
			#	Essentially, this works by testing that it didn't go anywhere.
			assert_equal current_path,
				new_study_subject_addressing_path(study_subject)
		end

		test "addressing#new should update blank city, state and county on zip code" <<
				" change with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_addressing_path(study_subject)
			assert find_field("addressing[address_attributes][city]").value.blank?
			assert find_field("addressing[address_attributes][county]").value.blank?
			assert find_field("addressing[address_attributes][state]").value.blank?
			assert find_field("addressing[address_attributes][zip]").value.blank?

			fill_in "addressing[address_attributes][zip]",  :with => "17857"

			assert_equal 'Northumberland',
				find_field("addressing[address_attributes][city]").value
			assert_equal 'Northumberland',
				find_field("addressing[address_attributes][county]").value
			assert_equal 'PA',
				find_field("addressing[address_attributes][state]").value
			assert_equal '17857',
				find_field("addressing[address_attributes][zip]").value
		end

	end

end
