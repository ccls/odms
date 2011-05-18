require 'test_helper'

class CasesControllerTest < ActionController::TestCase

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

#	site_editors.each do |cu|
#
#		test "should create waivered case with waivered as commit and #{cu} login" do
#			login_as send(cu)
#			post :create, :commit => 'waivered'
#			assert_redirected_to new_waivered_path
#		end
#
#		test "should create non-waivered case with nonwaivered as commit and #{cu} login" do
#			login_as send(cu)
#			post :create, :commit => 'nonwaivered'
#			assert_redirected_to new_nonwaivered_path
#		end
#
#		test "should NOT create case without commit as waivered or nonwaivered and #{cu} login" do
#			login_as send(cu)
#			post :create, :commit => 'somethingelse'
#			assert_redirected_to root_path
#		end
#
#		test "should NOT create case without commit and #{cu} login" do
#			login_as send(cu)
#			post :create
#			assert_redirected_to root_path
#		end
#
#	end
#
#	non_site_editors.each do |cu|
#
#		test "should NOT create waivered case with waivered as commit and #{cu} login" do
#			login_as send(cu)
#			post :create, :commit => 'waivered'
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT create non-waivered case with nonwaivered as commit and #{cu} login" do
#			login_as send(cu)
#			post :create, :commit => 'nonwaivered'
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT create case without commit as waivered or nonwaivered and #{cu} login" do
#			login_as send(cu)
#			post :create, :commit => 'somethingelse'
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#		test "should NOT create case without commit and #{cu} login" do
#			login_as send(cu)
#			post :create
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#	end
#
#	test "should NOT create waivered case with waivered as commit and without login" do
#		post :create, :commit => 'waivered'
#		assert_not_nil flash[:error]
#		assert_redirected_to_login
#	end
#
#	test "should NOT create non-waivered case with nonwaivered as commit and without login" do
#		post :create, :commit => 'nonwaivered'
#		assert_not_nil flash[:error]
#		assert_redirected_to_login
#	end
#
#	test "should NOT create case without commit as waivered or nonwaivered and without login" do
#		post :create, :commit => 'somethingelse'
#		assert_not_nil flash[:error]
#		assert_redirected_to_login
#	end
#
#	test "should NOT create case without commit and without login" do
#		post :create
#		assert_not_nil flash[:error]
#		assert_redirected_to_login
#	end

end
