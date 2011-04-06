require 'test_helper'

class OdmsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { :actions => [:show] }

	assert_access_with_login({
		:logins => [:superuser,:admin,:editor,
			:interviewer,:reader,:active_user] })
#		:logins => [:superuser,:admin,:editor,:interviewer,:reader] })
#	assert_no_access_with_login({
#		:logins => [:active_user] })
#	assert_no_access_without_login
	assert_access_without_login

	assert_access_with_https
	assert_no_access_with_http

end
