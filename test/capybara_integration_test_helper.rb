
#	Changing to use capybara from webrat in hopes of testing javascript.
#
#
#	So, so, so many hacks.  All to possibly test javascript.
#
#	All this probably slows a lot of stuff down.
#	About to run all the other stuff, and I expect a lot of failures.
#
#


require 'capybara/rails'

#Capybara.default_driver = :rack_test
#	Instructions say to set the javascript_driver, but when I did, it made no difference.
#Capybara.javascript_driver = :webkit
#	Instead if I set the default_driver, it runs ..
Capybara.default_driver = :webkit
#	On my home mac, ...
#	The first test fails, followed by ...
#Capybara-webkit server started, listening on port: 51803
#	Not all javascript tests work, however.
#	Looks like there is a bit of a problem with the alert/confirm pop-ups.
#	Will have to investigate these issues, as it would be nice to test javascript without a browser window coming open.
#	That being said, it would also be nice to test with all possibles so webkit, chrome and firefox
#		Unfortunately, not all test code is compatible with all the possible drivers.
#	cannot use switch_to for alert/confirm windows with webkit

#	port install qt4-mac
#	gem install capybara-webkit

#Capybara.default_driver = :selenium	#	defaults to firefox
#Capybara.default_driver = :selenium_chrome
#Capybara.default_driver = :selenium_firefox

#	There is no safari driver, so can't test in safari.
#Capybara.register_driver :selenium_safari do |app|
#	Capybara::Selenium::Driver.new(app, :browser => :safari)
#end

# Selenium::WebDriver::Error::WebDriverError: Unable to find the chromedriver executable. Please download the server from http://code.google.com/p/chromium/downloads/list and place it somewhere on your PATH. More info at http://code.google.com/p/selenium/wiki/ChromeDriver.
#	downloaded and installed 'chromedriver', which did open Chrome, 
#	but http://127.0.0.1:64647/fake_session/new
#	127.0.0.1 was rejected. The website may be down, or your network may not be properly configured.
#Here are some suggestions:
#Reload this webpage later.
#Check your Internet connection. Restart any router, modem, or other network devices you may be using.
#Add Google Chrome as a permitted program in your firewall's or antivirus software's settings. If it is already a permitted program, try deleting it from the list of permitted programs and adding it again.
#If you use a proxy server, check your proxy settings or contact your network administrator to make sure the proxy server is working. If you don't believe you should be using a proxy server, adjust your proxy settings: Go to Applications > System Preferences > Network > Advanced > Proxies and deselect any proxies that have been selected.
#
#	No joy.  It even kept re-testing without changing the code.
#
Capybara.register_driver :selenium_chrome do |app|
	Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

#	First ... Make sure Firefox is installed or set the path manually with Selenium::WebDriver::Firefox::Binary.path=
#	Then ...  Selenium::WebDriver::Error::WebDriverError: unable to start Firefox cleanly, args: ["-silent"]
require 'selenium/webdriver'
#	the firefox binary is currently not really compatible with command line as it contains 32 and 64bit.
#	if I 'ditto' it to strip off the unnecessary 64bit, I now get the same error as Chrome returns
#	'clearly' whatever is stopping me now will fix both firefox AND chrome
#	at least firefox doesn't keep trying over and over
#
#	this may be ssl related.  I thought that I had installed ssl on this machine.
#

if( Socket.gethostname == "mbp-3.local" )	#	jake's home machine
	Selenium::WebDriver::Firefox::Binary.path='/Applications/Firefox.app/Contents/MacOS/firefox-bin-leopard-dittod'
end
Capybara.register_driver :selenium_firefox do |app|
	Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

#	Using class_attribute instead of mattr_accessor so that
#	each subclass (read model) has its own value as we have
#	two databases meaning not all models have the same connection.
class ActiveRecord::Base
	class_attribute :saved_connection
	def self.connection
		saved_connection || retrieve_connection
	end
end



#	by creating separate subclasses, rather than just extending IntegrationTest, we can use both webrat and capybara
class ActionController::CapybaraIntegrationTest < ActionController::IntegrationTest

	setup :do_not_force_ssl
	def do_not_force_ssl
		#	fake all non-ssl JUST ON JAKE'S HOME MACBOOK as no ssl installed
#	actually ssl is a bit of a problem on dev.sph.berkeley.edu as well
#		probably has to do with the funky ports used and 
#		possible using 127.0.0.1 instead of localhost (shouldn't be)
#		if( Socket.gethostname == "mbp-3.local" )
			#	ApplicationController.subclasses does not initially include FakeSessionsController
			#	I explicitly 'ssl_allowed' new and create, so irrelevant.
			#	After the first request, it will be included though.
			ApplicationController.subclasses.each do |controller|
				controller.constantize.any_instance.stubs(:ssl_allowed?).returns(true) 
			end
#		end
	end

	setup :synchronize_selenium_connections
	def synchronize_selenium_connections
		#	if driver is selenium based, need to synchronize the transactional connections
		#
		###	initially based on http://pastie.org/1745020, but has changed
		#
		#		class ActiveRecord::Base
		#			mattr_accessor :shared_connection
		#			@@shared_connection = nil
		#			def self.connection
		#				@@shared_connection || retrieve_connection
		#			end
		#		end
		#		# Forces all threads to share the same connection. This works on
		#		# Capybara because it starts the web server in a thread.
		#		ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
		#
		###
		#
		#	connection hack for selenium
		#	with selenium, the database connection from the test and from the controllers are different
		#		and as the connections are transactional, I think, the test will be unaware of changes
		#		that the controller makes and the controller will be unaware of changes that the test makes.
		#		This seems to be why creating a user in the test does not result in a user being found in the controller.
		#		The same goes for the user's roles.
		#		It also means that the tests will not notice a difference after creating a page or other resource in the controller.
		#		So.  Apparently, we need a hack in all the models that will do this. Normally, we could just hack AR::Base,
		#		but since we already have 2 connection (one for shared, one for the app), we can't (unless I find a new way)
		#		So.  We need to individually hack any model that we may test.
		#
		#	I'd rather just loop through all the models, but there are a couple oddballs
		#	from use_db that may cause issues.  Still polishing this one.
		#	wonder what's gonna happen for modelless tables (roles_users)
#
#	Perhaps Shared.subclasses?
#
		[Address,Addressing,AddressType,County,Context,ContextDataSource,DataSource,
			Enrollment,Patient,PhoneNumber,PhoneType,StudySubject,ZipCode,
			SubjectLanguage,Language,SubjectRace,Race,
			OperationalEvent,OperationalEventType,Project,
			Guide,Page,Role,User].each do |model|
			model.saved_connection = model.connection
		end
	end

	include Capybara::DSL

#	apparently unnecessary
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
			page.visit new_fake_session_path()	#, { }, { 'HTTPS' => 'on' }
			page.fill_in 'id', :with => u.id
			page.click_button 'login'
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
