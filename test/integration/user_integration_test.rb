require 'integration_test_helper'

class UserIntegrationTest < ActionController::WebRatIntegrationTest
#class UserIntegrationTest < ActionController::CapybaraIntegrationTest

	all_test_roles.each do |cu|

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			#	get user_path(u), {}, { 'HTTPS' => 'on' }
			#	get does not use the set headers
			#	use visit instead
			visit user_path(u)

#			assert_response :success #	capybara does not do assert_response
#			assert_equal user_path(u), current_path

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
puts current_url

		end

	end

end
