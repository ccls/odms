require 'integration_test_helper'

class ContactsIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

#	contacts#show

##Capybara::ElementNotFound: no link with title, id or text '.toggle_eligibility_criteria' found
##			click_link '.toggle_eligibility_criteria'

		test "contacts#show should not have toggle_historic_addressings link" <<
				" without historic addressings and with #{cu} login" do
			addressing = Factory(:addressing,:current_address => YNDK[:yes])
			login_as send(cu)
			page.visit study_subject_contacts_path(addressing.study_subject)
			assert page.has_no_css?('a.toggle_historic_addressings')
			assert page.has_css?('div.addressings div.historic', :visible => false)
		end

		test "contacts#show should not have toggle_historic_phone_numbers link" <<
				" without historic phone_numbers and with #{cu} login" do
			phone_number = Factory(:phone_number,:current_phone => YNDK[:yes])
			login_as send(cu)
			page.visit study_subject_contacts_path(phone_number.study_subject)
			assert page.has_no_css?('a.toggle_historic_phone_numbers')
			assert page.has_css?('div.phone_numbers div.historic', :visible => false)
		end

		test "contacts#show should toggle historic addresses with #{cu} login" do
			addressing = Factory(:addressing,:current_address => YNDK[:no])
			login_as send(cu)
			page.visit study_subject_contacts_path(addressing.study_subject)
			assert page.has_css?('a.toggle_historic_addressings')
			assert page.has_css?('div.addressings div.historic', :visible => false)
			find('a.toggle_historic_addressings').click
			assert page.has_css?('div.addressings div.historic', :visible => true)
			find('a.toggle_historic_addressings').click
			assert page.has_css?('div.addressings div.historic', :visible => false)
		end

		test "contacts#show should toggle historic phone_numbers with #{cu} login" do
			phone_number = Factory(:phone_number,:current_phone => YNDK[:no])
			login_as send(cu)
			page.visit study_subject_contacts_path(phone_number.study_subject)
			assert page.has_css?('a.toggle_historic_phone_numbers')
			assert page.has_css?('div.phone_numbers div.historic', :visible => false)
			find('a.toggle_historic_phone_numbers').click
			assert page.has_css?('div.phone_numbers div.historic', :visible => true)
			find('a.toggle_historic_phone_numbers').click
			assert page.has_css?('div.phone_numbers div.historic', :visible => false)
		end

	end

end
