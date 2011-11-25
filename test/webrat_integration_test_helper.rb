#require "test_helper"

#	Webrat only works with integration tests which are a bit more difficult than
#	the unit and functional tests.  However, using webrat allows us to confirm
#	that the forms contain the necessary fields to create valid resources.

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

#class ActionController::IntegrationTest
class ActionController::WebRatIntegrationTest < ActionController::IntegrationTest
#	I guess that this isn't necessary
#	include CalnetAuthenticated::TestHelper

	fixtures :all

	setup :turn_https_on_for_webrat

	def turn_https_on_for_webrat
		#	I always, so far anyway, use https in webrat tests so ...
		header('HTTPS', 'on')
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

#	webrat doesn't actually maintain the sessions like capybara,
#		so we can explicitly post to the controller
#			post fake_session_path(), { :id => u.id }, { 'HTTPS' => 'on' }
#		or open the new fake_session and submit.  Either way.

			visit new_fake_session_path()	#, { }, { 'HTTPS' => 'on' }



			fill_in 'id', :with => u.id
#			fill_in 'uid', :with => u.uid




			click_button 'login'

#	moved into fake_session controller
#			CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
		end
	end

end

__END__

#	From http://cheat.errtheblog.com/s/webrat/

= Webrat - Ruby Acceptance Testing for Web applications

- http://gitrdoc.com/brynary/webrat
- http://groups.google.com/group/webrat
- http://webrat.lighthouseapp.com/
- http://github.com/brynary/webrat
- #webrat on Freenode

== Description

Webrat lets you quickly write expressive and robust acceptance tests for a Ruby
web application. 

== Features

* Browser Simulator for expressive, high level acceptance testing without the
  performance hit and browser dependency of Selenium or Watir (See
  Webrat::Session)
* Use the same API for Browser Simulator and real Selenium tests using
  Webrat::Selenium when necessary (eg. for testing AJAX interactions)
* Supports multiple Ruby web frameworks: Rails, Merb and Sinatra
* Supports popular test frameworks: RSpec, Cucumber, Test::Unit and Shoulda
* Webrat::Matchers API for verifying rendered HTML using CSS, XPath, etc.


== Simulating browser events

  # GET a URL, following any redirects, and making sure final page is successful
  visit "/some/url"

  # In general, elements can be located by their inner text, their 'title'
  attribute, their 'name' attribute, and their 'id' attribute.
  # They can be selected using a String, which is converted to an escaped Regexp
  effectively making it a substring match, or using a Regexp.
  # An exception is that using Strings for ids are compared exactly (using ==)
  rather than converted to a Regexp
  # If the element you are trying to look up does not exist, an error occurs


  # Links can be looked up by text, title, or id
  # To match... <a href="/signup" title="Sign up" id="signup_link">Click here to
  join!</a>
  click_link "Click here to join!" # substring text
  click_link /join/i               # regexp text
  click_link "Sign up"             # substring title
  click_link /sign.*up/i           # regexp title
  click_link /signup.*link/i       # regexp id
  click_link "signup_link"         # exact id


  # All fields can be looked up by ID, name, or label inner text

  # text fields, password fields, and text areas can be filled in
  # <label for="user[email]">Enter your Email</label><input type="text"
  name="user[email]" id="user_email">
  fill_in "user_email", :with => "good@example"      # exact id
  fill_in /user.*email/, :with => "good@example"     # regexp id
  fill_in "user[email]", :with => "good@example"     # substring name
  fill_in /user[.*mail.*]/, :with => "good@example"  # substring name
  fill_in "Email", :with => "good@example.com"       # substring label text
  fill_in /enter your email/i, :with => "good@example.com" # regexp label text

  # Hidden fields can be set
  set_hidden_field 'user[l337_hax0r]', :to => 'true'

  # Select options can be 'selected' by inner text (an exact String or a Regexp
  to match). It can optionally be selected from a particular select field, using
  the usual id, name, or label text.
  select "Free account"
  select "Free account", :from => "Account Types"
  select "Free account", :from => "user[account_type]"
  select "Free account", :from => "user_account_type"


  # Check boxes can be 'checked' and 'unchecked'
  check 'Remember me'
  uncheck 'Remember me'

  # Radio buttons can be choosen, using the usual label text, name, or id.
  choose "Yes"

  click_button "Register"

== Assertions

   # check for text in the body of html tags
   # can be a string or regexp
  assert_contain("BURNINATOR")
  assert_contain(/trogdor/i)
  assert_not_contain("peasants")

  # check for a css3 selector
  assert_have_selector 'div.pagination'
  assert_have_no_selector 'form input#name'


== Matchers

  # check for text in the body of html tags
  # can be a string or regexp
  # Matchers are verbs used with auxillary verbs should, should_not, etc.
  response.should contain("BURNINATOR")
  response.should contain(/trogdor/i)
  response.should_not contain("peasants")

  # check for a css3 selector
  response.should have_selector('div.pagination')
  response.should_not have_selector('form input#name')

  # check for the current URL (after all redirects, etc.)
  current_url.should == 'http://www.example.com/'      # RSpec
  assert_equal('http://www.example.com/', current_url) # Test::Unit
  

== Targetted actions/matchers

  # selectors syntax is defined here: http://www.w3.org/TR/css3-selectors/
  within 'div.pagination' do |scope|
    scope.click_link "1"
  end

  within '.shows' do |scope|
    scope.should contain("NFL")
    # unfortunately, assertions don't support this currently
  end

  within 'form[name="search"] select[name="type"]' do |scope|
    scope.should have_selector 'option[value="blah"]'
    scope.should have_selector 'option[value="gah"]'
    scope.should have_selector 'option[value="eep"]'
    scope.should have_selector 'input:only-of-type'
    scope.should have_selector 'input[name="query"]'
    scope.should have_selector 'input[type="text"]'
  end

