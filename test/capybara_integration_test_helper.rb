require "test_helper"

#	Webrat only works with integration tests which are a bit more difficult than
#	the unit and functional tests.  However, using webrat allows us to confirm
#	that the forms contain the necessary fields to create valid resources.
#	Changing to use capybara from webrat in hopes of testing javascript.

#require "capybara"
require 'capybara/rails'

#Webrat.configure do |config|
#  config.mode = :rails
#end

#Capybara.default_driver = :selenium

class ActionController::IntegrationTest
	include Capybara::DSL
	include CalnetAuthenticated::TestHelper

	fixtures :all

	setup :turn_https_on_for_capybara

	def turn_https_on_for_capybara
#puts Capybara.current_driver.inspect
#puts Capybara.methods.sort
#puts self.class.current_driver
#puts Capybara.inspect
#puts @driver.response_headers.inspect
		#	I always, so for anyway, use https in capybara tests so ...
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
			#	Still not using the @session provided by integration testing (open_session)
			post fake_session_path(), { :id => u.id }, { 'HTTPS' => 'on' }
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
