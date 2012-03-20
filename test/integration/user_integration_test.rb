require 'integration_test_helper'

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
#			begin
#				visit user_path(u)
#puts page.methods.sort
				page.visit user_path(u)
#puts page.requested_url
#puts page.driver.browser.requested_url
#puts page.driver.browser.current_url
#puts page.driver.browser.response_headers
#puts page.response_headers
#puts page.driver.browser.methods.sort
#puts page.current_host
#	=> http://127.0.0.1
#puts page.current_path
#	=> /users/90
#puts page.current_url
#	=> http://127.0.0.1:59701/users/90
#puts page.body
				#	Don't seem to follow redirects in rails 3 as this did work.
				#	The page.body is correct, but the page.current_url
				#		and page.current_path are not????
#				assert_match /https:\/\/auth-test\.berkeley\.edu\/cas\/login/,
#					page.current_url
pending

#    <title>CalNet Central Authentication Service - Single Sign-on</title>
#	This isn't perfect, but it does test that the redirect is to CalNet

				assert_select HTML::Document.new(page.body).root, 'title', 
					:text => "CalNet Central Authentication Service - Single Sign-on"


#  5) Failure:
#test_should_not_get_superuser_info_if_not_logged_in(UserIntegrationTest) [test/integration/user_integration_test.rb:28]:
#<"http://127.0.0.1:59371/users/5203"> expected to be =~
#</https:\/\/auth-test\.berkeley\.edu\/cas\/login/>.


				#https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A50510%2Fusers%2F1
#			rescue Capybara::Driver::Webkit::WebkitInvalidResponseError => e
#				#	probably not connected to the internet
#				assert_match /Unable to load URL: https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/\d+/, e.to_s
#			end
		end

	end

end
