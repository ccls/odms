require 'integration_test_helper'

class UserIntegrationTest < ActionController::WebRatIntegrationTest

	all_test_roles.each do |cu|

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			#	get user_path(u), {}, { 'HTTPS' => 'on' }
			#	get does not use the set headers
			#	use visit instead
			visit user_path(u)
			assert_response :success
			assert_not_nil assigns(:user)
			assert_equal u, assigns(:user)
		end

		test "should not get #{cu} info if not logged in" do
			u = send(cu)
			#	get user_path(u), {}, { 'HTTPS' => 'on' }
			#	get does not use the set headers
			#	use visit instead
			visit user_path(u)
			assert_redirected_to_login
		end

	end

end
