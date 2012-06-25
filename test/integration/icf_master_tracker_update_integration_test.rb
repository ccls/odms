require 'integration_test_helper'

class IcfMasterTrackerUpdateIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

		test "should toggle csv file content with #{cu} login" do
			icf_master_tracker_update = Factory(:empty_icf_master_tracker_update)
			login_as send(cu)
			visit icf_master_tracker_update_path(icf_master_tracker_update)
			assert has_css?('#csv_file_content', :visible => false)
			find('a.toggles_csv_file_content').click
			assert has_css?('#csv_file_content', :visible => true)
			find('a.toggles_csv_file_content').click
			assert has_css?('#csv_file_content', :visible => false)

# i think that this is needed, but check
#     icf_master_tracker_update.destroy  # explicitly cleanup attachment
		end

	end

end
