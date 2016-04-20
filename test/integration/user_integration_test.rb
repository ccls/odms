require 'integration_test_helper'

class UserIntegrationTest < ActionDispatch::CapybaraIntegrationTest

	all_test_roles.each do |cu|

		test "should logout with #{cu} login" do
			#	In anticipation that may not be connected to the internet,
			#	open begin block with rescue ...
			begin
				u = send(cu)
				login_as u
				visit root_path
				assert_equal root_path, current_path
				click_link "Logout"
				assert_equal "/cas/logout", current_path
			rescue Capybara::Webkit::InvalidResponseError => e
				#	probably not connected to the internet

				#	Unable to load URL: http://127.0.0.1:53128/logout because of error loading https://auth-test.berkeley.edu/cas/logout?destination=http%3A%2F%2F127.0.0.1%3A53128%2F&gateway=true: Unknown error

				assert_match /Unable to load URL: .* https:\/\/auth-test.berkeley.edu\/cas\/logout\?destination=http%3A%2F%2F\d+\.\d+\.\d+\.\d+%3A\d+%2F&gateway=true: Unknown error/, e.to_s
				assert_match /Unable to load URL: http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/logout because of error loading https:\/\/auth-test.berkeley.edu\/cas\/logout\?destination=http%3A%2F%2F\d+\.\d+\.\d+\.\d+%3A\d+%2F&gateway=true: Unknown error/, e.to_s

			end
		end

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			visit user_path(u)

			assert_equal user_path(u), current_path

			page_body = body.to_html_document
			assert_select page_body, 'title', :text => "CCLS ODMS"

			assert_select( page_body, 'div#main', 1 ){
			assert_select( 'div#content', 1 ){
			assert_select( 'fieldset#user', 1 ){
				assert_select( 'legend', 1 )
				assert_select( 'div.person', 1 )
			} } }
		end

		test "should not get #{cu} info if not logged in" do
			#	In anticipation that may not be connected to the internet,
			#	open begin block with rescue ...
			begin
				u = send(cu)
				visit user_path(u)

				#	Doesn't seem to follow redirects in rails 3 as this did work in rails 2.
				#	The page.body is correct, but the page.current_url
				#		and page.current_path are not????
				#	Seems to work again in rails 4.  Not sure which gem is responsible.
				assert_match /https:\/\/auth-test\.berkeley\.edu\/cas\/login/, current_url

#	NOTE current_url is not following redirect (now it is?)

				#<title>CalNet Central Authentication Service - Single Sign-on</title>

				#	This isn't perfect, but it does test that the redirect is to CalNet
				#	If I can't test that I've been redirected, test the page content.
				assert_select body.to_html_document, 'title', 
					:text => "CalNet Central Authentication Service - Single Sign-on"

				#https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A50510%2Fusers%2F1

#	20130329 - Seems this exception has changed its name and error message format (at least on my macbook)
#Capybara::Webkit::InvalidResponseError: Unable to load URL: http://127.0.0.1:58094/users/1 because of error loading https://auth-test.berkeley.edu/cas/login?service=http://127.0.0.1:58094/users/1: Host  not found

			rescue Capybara::Webkit::InvalidResponseError => e
				#	probably not connected to the internet

				#	Unable to load URL: http://127.0.0.1:52788/users/1 because of error loading https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A52788%2Fusers%2F1: Unknown error

				#	seems that the url is now encoded

#				assert_match /Unable to load URL: .* https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/\d+/, e.to_s
#	Unable to load URL: http://127.0.0.1:53395/users/1 because of error loading https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A53395%2Fusers%2F1: Unknown error
				assert_match /Unable to load URL: .* https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http%3A%2F%2F\d+\.\d+\.\d+\.\d+%3A\d+%2Fusers%2F\d+/, e.to_s
				assert_match /Unable to load URL: http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/1 because of error loading https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http%3A%2F%2F\d+\.\d+\.\d+\.\d+%3A\d+%2Fusers%2F\d+/, e.to_s

#
#	Expected /Unable to load URL: .* https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/\d+/ to match "Unable to load URL: http://127.0.0.1:50904/users/1 because of error loading https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A50904%2Fusers%2F1: Unknown error".
#

#			rescue Capybara::Driver::Webkit::WebkitInvalidResponseError => e
#				#	probably not connected to the internet
#				assert_match /Unable to load URL: https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/\d+/, e.to_s
			end
		end

	end

end
