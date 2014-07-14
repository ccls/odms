require 'integration_test_helper'

class UserIntegrationTest < ActionDispatch::CapybaraIntegrationTest

	all_test_roles.each do |cu|

		test "should logout with #{cu} login" do
			u = send(cu)
			login_as u
			visit root_path
			assert_equal root_path, current_path
			click_link "Logout"
			assert_equal "/cas/logout", current_path
		end

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			visit user_path(u)

			assert_equal user_path(u), current_path

			page_body = HTML::Document.new(body).root
			assert_select page_body, 'title', :text => "CCLS ODMS"
			assert_select( page_body, 'div#main', 1 ){|main|	#	Array!
			assert_select( main.first,    'div#content', 1 ){ |content|	#	Array!
			assert_select( content.first, 'fieldset#user', 1 ){ |fieldset|	#	Array!
				assert_select( fieldset.first, 'legend', 1 )
				assert_select( fieldset.first, 'div.person', 1 )
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

#	NOTE current_url is not following redirect

				#<title>CalNet Central Authentication Service - Single Sign-on</title>

				#	This isn't perfect, but it does test that the redirect is to CalNet
				#	If I can't test that I've been redirected, test the page content.
				assert_select HTML::Document.new(body).root, 'title', 
					:text => "CalNet Central Authentication Service - Single Sign-on"

				#https://auth-test.berkeley.edu/cas/login?service=http%3A%2F%2F127.0.0.1%3A50510%2Fusers%2F1

#	20130329 - Seems this exception has changed its name and error message format (at least on my macbook)
#Capybara::Webkit::InvalidResponseError: Unable to load URL: http://127.0.0.1:58094/users/1 because of error loading https://auth-test.berkeley.edu/cas/login?service=http://127.0.0.1:58094/users/1: Host  not found

			rescue Capybara::Webkit::InvalidResponseError => e
				#	probably not connected to the internet
				assert_match /Unable to load URL: .* https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/\d+/, e.to_s

#			rescue Capybara::Driver::Webkit::WebkitInvalidResponseError => e
#				#	probably not connected to the internet
#				assert_match /Unable to load URL: https:\/\/auth-test.berkeley.edu\/cas\/login\?service=http:\/\/\d+\.\d+\.\d+\.\d+:\d+\/users\/\d+/, e.to_s
			end
		end

	end

end
