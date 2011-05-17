require 'test_helper'

class CaseWizardsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:actions => [:new]
	}

	assert_access_with_login({
		:logins => site_editors })

	assert_no_access_with_login({
		:logins => non_site_editors })

	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http





#	create will be complicated





end
