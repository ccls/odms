require 'integration_test_helper'

class UserIntegrationTest < ActionController::IntegrationTest

	def xxx_setup
		@session = open_session # or ActionController::Integration::Session.new
		assert !@session.https?
		@session.https!
		assert @session.https?
	end

	all_test_roles.each do |cu|

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			get user_path(u), {}, { 'HTTPS' => 'on' }
			assert_response :success
			assert_not_nil assigns(:user)
			assert_equal u, assigns(:user)
		end

		test "should not get #{cu} info if not logged in" do
			u = send(cu)
			get user_path(u), {}, { 'HTTPS' => 'on' }
			assert_redirected_to_login

#			@session.get user_path(u)
#			@session.assert_response :redirect
#			assert_match "https://auth-test.berkeley.edu/cas/login",
#				@session.response.redirected_to
		end

	end

end
