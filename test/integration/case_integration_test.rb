require 'integration_test_helper'

class CaseIntegrationTest < ActionController::CapybaraIntegrationTest

	site_administrators.each do |cu|

		test "should render html and trigger csv download "<<
				"on assigned_for_interview_at with #{cu} login"
pending
		end

	end

end
