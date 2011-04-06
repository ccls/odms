require 'test_helper'

class CaseWizardsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:actions => [:new]
	}

	assert_access_with_login({
		:logins => [:superuser,:admin,:editor ] })

	assert_no_access_with_login({
		:logins => [:interviewer,:reader,:active_user] })

	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http





#	create will be complicated





end
