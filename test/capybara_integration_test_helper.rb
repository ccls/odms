require "test_helper"

#	Webrat only works with integration tests which are a bit more difficult than
#	the unit and functional tests.  However, using webrat allows us to confirm
#	that the forms contain the necessary fields to create valid resources.
#	Changing to use capybara from webrat in hopes of testing javascript.

require 'capybara/rails'

#Capybara.default_driver = :selenium
#Make sure Firefox is installed or set the path manually with Selenium::WebDriver::Firefox::Binary.path=


#class ActionController::IntegrationTest
#class CapybaraIntegrationTest < ActionController::IntegrationTest
class ActionController::CapybaraIntegrationTest < ActionController::IntegrationTest
	include Capybara::DSL
#	include CalnetAuthenticated::TestHelper

	fixtures :all

#	setup :turn_https_on_for_capybara

	def turn_https_on_for_capybara
		#	this seems like it may not be necessary
		#	It appears that if the first request uses https, which the login does,
		#	this is preserved, or at least the GET requests follow the redirect.
		#	Not entirely sure just yet.
		#	Protocol seems to be preserved.

#	capybara is starting suck worse than webrat did.
#	Of course, I ended up figuring that one out so ...

#???
#
#Using the sessions manually
#
#For ultimate control, you can instantiate and use a Session manually.
#
#require 'capybara'
#
#session = Capybara::Session.new(:culerity, my_rack_app)
#session.within("//form[@id='session']") do
#  session.fill_in 'Login', :with => 'user@example.com'
#  session.fill_in 'Password', :with => 'password'
#end
#session.click_link 'Sign in'

# also see ...
#	http://stackoverflow.com/questions/6605364
#	about requesting through the page and driver?
#	page.driver.post user_session_path, :user => {:email => user.email, :password => 'superpassword'}

# Its always amazing how simple and powerful someone can make
#	something look in a little demo.  Of course, they are ignoring
#	all the complicated things that are gonna piss you off.
#	None of the demos talk about the session or ssl.  Not one.

#puts Capybara.current_driver.inspect
#puts Capybara.methods.sort
#puts self.class.current_driver
#puts Capybara.inspect
#puts @driver.response_headers.inspect
		#	I always, so far anyway, use https in capybara tests so ...
#		header('HTTPS', 'on')
	end

	#	Special login_as for integration testing.
	def login_as( user=nil )
		uid = ( user.is_a?(User) ) ? user.uid : user
		if !uid.blank?
			stub_ucb_ldap_person()
			u = User.find_create_and_update_by_uid(uid)
			#	Rather than manually manipulate the session,
			#	I created a fake controller to do it.
#	works for rack_test
#			page.driver.post fake_session_path(), { :id => u.id }, { 'HTTPS' => 'on' }
#	not for selenium
#	almost got selenium working, but now Firefox actually complains and I get ...
#	Selenium::WebDriver::Error::WebDriverError: unable to start Firefox cleanly, args: ["-silent"]
#
#	rather than manually do this post, may want to create new_fake_session, form fill it in, then click submit?
#			page.driver.browser.post fake_session_path(), { :id => u.id }, { 'HTTPS' => 'on' }
			page.visit new_fake_session_path()	#, { }, { 'HTTPS' => 'on' }
#puts page.body
			page.fill_in 'id', :with => u.id
			page.click_button 'login'
			CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
		end
	end

end

__END__

#	From http://cheat.errtheblog.com/s/capybara/

Capybara
========

Webrat alternative which aims to support all browser simulators.

API
===

Navigating
----------

visit articles_path

Clicking links and buttons
--------------------------

click 'Link Text' 
click_button
click_link

Interacting with forms
----------------------

attach_file
fill_in 'First Name', :with => 'John'
check
uncheck
choose
select
unselect

Querying
--------

Takes a CSS selector (or XPath if you're into that).
Translates nicely into RSpec matchers:

page.should have_no_button("Save")

Use should have_no_* versions with RSpec matchers b/c
should_not doesn't wait for a timeout from the driver

page.has_content?
page.has_css?
page.has_no_content?
page.has_no_css?
page.has_no_xpath?
page.has_xpath?
page.has_link?
page.has_no_link?
page.has_button?("Update")
page.has_no_button?
page.has_field?
page.has_no_field?
page.has_checked_field?
page.has_unchecked_field?
page.has_no_table?
page.has_table?
page.has_select?
page.has_no_select?

Finding
-------

find
find_button
find_by_id
find_field
find_link
locate

Scoping
-------

within
within_fieldset
within_table
within_frame
scope_to

Scripting
---------

execute_script
evaluate_script

Debugging
---------

save_and_open_page

Miscellaneous
-------------

all
body
current_url
drag
field_labeled
source
wait_until
current_path
