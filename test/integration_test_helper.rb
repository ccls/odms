require 'test_helper'
require 'capybara_integration_test_helper'

class ActionController::CapybaraIntegrationTest

	# wait_until has been removed in Capybara > 2.0
	#	effectively just a yield wrapped in a timeout
	def wait_until
		yield
	end

end
