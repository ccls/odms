require 'test_helper'

class OdmsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { :actions => [:show],
		:skip_show_failure => true }

	assert_access_with_login({ :logins => all_test_roles })
	assert_access_without_login

end
