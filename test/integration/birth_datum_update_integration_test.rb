require 'integration_test_helper'

class BirthDatumUpdateIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

		test "should toggle csv file content with #{cu} login" do
			birth_datum_update = Factory(:empty_birth_datum_update)
			login_as send(cu)
			visit birth_datum_update_path(birth_datum_update)
			assert has_css?('#csv_file_content', :visible => false)
			find('a.toggles_csv_file_content').click
			assert has_css?('#csv_file_content', :visible => true)
			find('a.toggles_csv_file_content').click
			assert has_css?('#csv_file_content', :visible => false)
		end

	end

end
