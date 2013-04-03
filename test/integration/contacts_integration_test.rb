require 'integration_test_helper'

class ContactsIntegrationTest < ActionController::CapybaraIntegrationTest

	site_editors.each do |cu|

#	contacts#show

		test "contacts#show should not have toggle_historic_addressings link" <<
				" without historic addressings and with #{cu} login" do
			addressing = FactoryGirl.create(:addressing,:current_address => YNDK[:yes])
			login_as send(cu)
			visit study_subject_contacts_path(addressing.study_subject)
			assert has_no_css?('a.toggler.toggles_historic_addressings')
			assert has_css?('div.addressings div#historic_addressings', :visible => false)
		end

		test "contacts#show should not have toggle_historic_phone_numbers link" <<
				" without historic phone_numbers and with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number,:current_phone => YNDK[:yes])
			login_as send(cu)
			visit study_subject_contacts_path(phone_number.study_subject)
			assert has_no_css?('a.toggler.toggles_historic_phone_numbers')
			assert has_css?('div.phone_numbers div#historic_phone_numbers', :visible => false)
		end

		test "contacts#show should toggle historic addresses with #{cu} login" do
			addressing = FactoryGirl.create(:addressing,:current_address => YNDK[:no])
			login_as send(cu)
			visit study_subject_contacts_path(addressing.study_subject)
			assert has_css?('a.toggler.toggles_historic_addressings')
			assert has_css?('div.addressings div#historic_addressings', :visible => false)
			find('a.toggles_historic_addressings').click
			assert has_css?('div.addressings div#historic_addressings', :visible => true)
			find('a.toggles_historic_addressings').click
			assert has_css?('div.addressings div#historic_addressings', :visible => false)
		end

		test "contacts#show should toggle historic phone_numbers with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number,:current_phone => YNDK[:no])
			login_as send(cu)
			visit study_subject_contacts_path(phone_number.study_subject)
			assert has_css?('a.toggler.toggles_historic_phone_numbers')
			assert has_css?('div.phone_numbers div#historic_phone_numbers', :visible => false)
			find('a.toggles_historic_phone_numbers').click
			assert has_css?('div.phone_numbers div#historic_phone_numbers', :visible => true)
			find('a.toggles_historic_phone_numbers').click
			assert has_css?('div.phone_numbers div#historic_phone_numbers', :visible => false)
		end

	end

end
