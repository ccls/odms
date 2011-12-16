require 'integration_test_helper'

#class UserIntegrationTest < ActionController::WebRatIntegrationTest
class UserIntegrationTest < ActionController::CapybaraIntegrationTest

	all_test_roles.each do |cu|

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			#	get user_path(u), {}, { 'HTTPS' => 'on' }
			#	get does not use the set headers
			#	use page.visit instead (page.visit seems to preserve session)
			page.visit user_path(u)
			assert_equal user_path(u), current_path

#			assert_response :success #	capybara does not do assert_response
#			assert_not_nil assigns(:user)	#	capybara doesn't use assigns
#			assert_equal u, assigns(:user)	#	capybara doesn't use assigns
		end

		test "should not get #{cu} info if not logged in" do
			u = send(cu)
			#	get user_path(u), {}, { 'HTTPS' => 'on' }
			#	get does not use the set headers
			#	use visit instead
			visit user_path(u)

#			assert_redirected_to_login #	capybara follows redirects
			assert_match /https:\/\/auth-test\.berkeley\.edu\/cas\/login/,
				current_url
#https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A50510%2Fusers%2F1



		end

	end

end
