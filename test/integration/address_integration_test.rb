require 'integration_test_helper'

class AddressIntegrationTest < ActionDispatch::CapybaraIntegrationTest

	site_editors.each do |cu|

		test "address#edit should update blank address info on zip code change" <<
				" with #{cu} login" do
			address = FactoryGirl.create(:address)
			login_as send(cu)
			visit edit_study_subject_address_path(address.study_subject,address)
			fill_in "address[city]",  :with => ""
			fill_in "address[county]",  :with => ""
			select "", :from => 'address[state]'
			fill_in "address[zip]",  :with => ""
			assert find_field("address[city]").value.blank?
			assert find_field("address[county]").value.blank?
			assert find_field("address[state]").value.blank?
			assert find_field("address[zip]").value.blank?

			fill_in "address[zip]",  :with => "17857"

			#	in capybara 2.4.1, change focus so change gets triggered? (unneeded in #new)?
			#execute_script("document.getElementById('address_zip').blur()")
			# ... or ... 
			#find_field("address[line_1]").click
			find("body").click

			assert_equal 'Northumberland',
				find_field("address[city]").value
			assert_equal 'Northumberland',
				find_field("address[county]").value
			assert_equal 'PA',
				find_field("address[state]").value
			assert_equal '17857',
				find_field("address[zip]").value
		end

		test "address#edit should show other_data_source when 'Other Source'" <<
				" data_source is selected with #{cu} login" do
			address = FactoryGirl.create(:address)
			login_as send(cu)
			visit edit_study_subject_address_path(address.study_subject,address)
			assert !( find_field('address[other_data_source]', :visible => false).visible? ),
				"address other data source is visible and shouldn't be (connected?)."
			select "Other Source", :from => 'address[data_source]'
			assert find_field('address[other_data_source]').visible?,
				"address other data source is NOT visible and should be (connected?)."
			select "", :from => 'address[data_source]'
			assert !( find_field('address[other_data_source]', :visible => false).visible? ),
				"address other data source is visible and shouldn't be (connected?)."
			select "Other Source", :from => 'address[data_source]'
			assert find_field('address[other_data_source]').visible?,
				"address other data source is NOT visible and should be (connected?)."
		end

		test "address#edit should show subject_moved when residence address" <<
				" current_address is changed to 'No' with #{cu} login" do
			address = FactoryGirl.create(:current_residence_address)
			login_as send(cu)
			visit edit_study_subject_address_path(address.study_subject,address)
			assert !( find_field('address[subject_moved]', :visible => false).visible? ),
				"address subject moved is visible and shouldn't be (connected?)."
			select "No", :from => 'address[current_address]'
			assert find_field('address[subject_moved]').visible?,
				"address subject moved is NOT visible and should be (connected?)."
			select "", :from => 'address[current_address]'
			assert !( find_field('address[subject_moved]', :visible => false).visible? ),
				"address subject moved is visible and shouldn't be (connected?)."
			select "No", :from => 'address[current_address]'
			assert find_field('address[subject_moved]').visible?,
				"address subject moved is NOT visible and should be (connected?)."
		end

		test "address#edit should NOT show subject_moved when residence address" <<
				" current_address is changed to 'Don't Know' with #{cu} login" do
			address = FactoryGirl.create(:current_residence_address)
			login_as send(cu)
			visit edit_study_subject_address_path(address.study_subject,address)
			assert !( find_field('address[subject_moved]', :visible => false).visible? ),
				"address subject moved is visible and shouldn't be (connected?)."
			select "Don't Know", :from => 'address[current_address]'
			assert !( find_field('address[subject_moved]', :visible => false).visible? ),
				"address subject moved is visible and shouldn't be (connected?)."
			select "", :from => 'address[current_address]'
			assert !( find_field('address[subject_moved]', :visible => false).visible? ),
				"address subject moved is visible and shouldn't be (connected?)."
			select "Don't Know", :from => 'address[current_address]'
			assert !( find_field('address[subject_moved]', :visible => false).visible? ),
				"address subject moved is visible and shouldn't be (connected?)."
		end

#	address#new

		test "address#new should show confirm when new residence address is" <<
				" submitted with state not 'CA' and #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_address_path(study_subject)
			#	residence address and NOT in 'CA'
			select 'PA', :from => "address[state]"
			select 'Residence', :from => "address[address_type]"

			#	we don't want to actually save, so cancel with ....
			execute_script('window.confirm = function() { return false; }')
#			evaluate_script('window.confirm = function() { return false; }')


#	execute_script(script)
#	Execute the given script, not returning a result. This is useful for scripts that return complex objects, such as jQuery statements. execute_script should be used over evaluate_script whenever possible.
#	evaluate_script(script)
#	Evaluate the given JavaScript and return the result. Be careful when using this with scripts that return complex objects, such as jQuery statements. execute_script might be a better alternative.



			click_button 'Save'

			#	Without overriding the confirm function, clicking save will submit
			#		and the current_path would be /study_subjects/:id/addresses
			#	When confirm returns false, it will stay at same path.
			#	Essentially, this works by testing that it didn't go anywhere.
			assert_equal current_path,
				new_study_subject_address_path(study_subject)
		end

		test "address#new should update blank city state and county on zip code" <<
				" change with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			visit new_study_subject_address_path(study_subject)
			assert find_field("address[city]").value.blank?
			assert find_field("address[county]").value.blank?
			assert find_field("address[state]").value.blank?
			assert find_field("address[zip]").value.blank?

			fill_in "address[zip]",  :with => "17857"

			#	in capybara 2.4.1, change focus so change gets triggered? (unneeded in #new)?
			#execute_script("document.getElementById('address_zip').blur()")
			# ... or ... 
			#find_field("address[line_1]").click
			find("body").click

			#	now it seems to be needed in #new.  i love consistency

			assert_equal 'Northumberland',
				find_field("address[city]").value
			assert_equal 'Northumberland',
				find_field("address[county]").value
			assert_equal 'PA',
				find_field("address[state]").value
			assert_equal '17857',
				find_field("address[zip]").value
		end

	end

end


#	the visible? test is stupid now if it won't find it unless its visible!

#	the visible option isn't whether the element is visible, it is whether to consider visibility

#	I'd kinda like to set this as the default option, otherwise I have to change all of them.

