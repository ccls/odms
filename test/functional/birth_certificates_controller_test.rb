require 'test_helper'

class BirthCertificatesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:actions => [:index]#,
#		:method_for_create => :create_bc_request 
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

end
