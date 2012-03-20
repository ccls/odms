require 'capybara/rails'

#	Explicitly require the FakeSessionsController
require 'test/app/controllers/fake_sessions_controller'


#
#	Capybara.default_drivers [ :rack_test, :selenium/:selenium_firefox, 
#		:selenium_chrome, :selenium_safari, :webkit ]
#
#		Unfortunately, each driver has different abilities and limitations.  
#			We cannot develop for all of them.  We must choose.
#			I chose capybara-webkit ( or just webkit ).
#
#		Capybara.default_driver = :rack_test
#			This is the default driver, but does not support javascript.  
#			This is effectively the same as webrat, although the DSL is a 
#			bit different.  Webrat is still used a bit, but as these
#			integration tests are primarily used to test javascript, 
#			all of my new tests are capybara based and do not use rack_test
#
#		Capybara.default_driver = :selenium	#	defaults to firefox
#			This is a decent tester, but will actually open a browser window
#			which you can watch.
#			selenium can interact with alert/confirm pop-ups...
#				press Cancel by ...
#					page.driver.browser.switch_to.alert.dismiss
#				press OK by ...
#					page.driver.browser.switch_to.alert.accept
#			selenium can also check the content of this window...
#				page.driver.browser.switch_to.alert.text
#
#		Capybara.default_driver = :selenium_firefox
#			:selenium_firefox does not exist, but could be defined with ...
#				Capybara.register_driver :selenium_firefox do |app|
#					Capybara::Selenium::Driver.new(app, :browser => :firefox)
#				end
#			This is effectively the same as :selenium, as firefox is its default.
#			I have found a bit of a catch when using this on my MacBook Pro.  
#			There is a bit of a problem with using the firefox binary, which 
#			includes both 32 and 64 bit versions, on a 32-bit machine.  The 
#			64-bit code must be removed. I ...
#				cd /Applications/Firefox.app/Contents/MacOS/
#				ditto --arch i386 firefox-bin firefox-bin-leopard-dittod
#			This results in the requirement to specify this new binary to 
#			be used with ...
#			if( Socket.gethostname == "mbp-3.local" )	#	jake's home machine
#				Selenium::WebDriver::Firefox::Binary.path=
#					'/Applications/Firefox.app/Contents/MacOS/firefox-bin-leopard-dittod'
#			end
#			In addition, to use any selenium, the following is required...
#				require 'selenium/webdriver'
#
#		Capybara.default_driver = :selenium_chrome
#			In order to test with chrome, the chromedriver must be downloaded.  
#			It is just a single file, and must placed in the path.  Without 
#			it, you will see ...
#				Selenium::WebDriver::Error::WebDriverError: 
#					Unable to find the chromedriver executable. 
#				Please download the server from 
#					http://code.google.com/p/chromium/downloads/list and 
#				place it somewhere on your PATH. More info at 
#					http://code.google.com/p/selenium/wiki/ChromeDriver.
#			As this driver does not exist, it will need to be defined/registered with ...
#				Capybara.register_driver :selenium_chrome do |app|
#					Capybara::Selenium::Driver.new(app, :browser => :chrome)
#				end
#			In addition, to use any selenium, the following is required...
#				require 'selenium/webdriver'
#
#		Capybara.default_driver = :selenium_safari
#			There is no safari driver, so can't test in safari.  If there were, ...
#			Capybara.register_driver :selenium_safari do |app|
#				Capybara::Selenium::Driver.new(app, :browser => :safari)
#			end
#
#		Capybara.default_driver = :webkit ( capybara-webkit )
#			I have chosen to use webkit.  It requires a bit more installation, 
#			but is cleaner.  There are also a few things that do not work, 
#			mostly with respect to the alert/confirm pop-up windows.
#			We cannot use switch_to for alert/confirm windows with webkit, 
#			as was done with selenium. We also cannot test the content
#			of an alert/confirm pop-up window.
#			webkit seems to automatically click ok on alert and confirm
#			pop-ups.  In order to override this and click 'Cancel',
#			something like ...
#				page.evaluate_script('window.confirm = function() { return false; }')
#			can be used.
#			In order to use webkit, qt4 must be installed before the gem.  
#			On a mac, ...
#				port install qt4-mac
#				gem install capybara-webkit
#			Instructions say to set the javascript_driver, but when I did, 
#			it made no difference.
#				Capybara.javascript_driver = :webkit
#			Instead if I set the default_driver, it runs ..
#				Capybara.default_driver = :webkit
#
#			webkit and selenium do not support transactional fixtures as they 
#				are in different threads and therefore do not share a database 
#				connection between the test and the browser.  A patch for this 
#				is to force a single database connection for each model.  
#				It works, but is more of a hack.
#			

Capybara.default_driver = :webkit

#	Using class_attribute instead of mattr_accessor so that
#	each subclass (read model) has its own value as we have
#	two databases meaning not all models have the same connection.
class ActiveRecord::Base
	class_attribute :saved_connection
	def self.connection
		saved_connection || retrieve_connection
	end
end
#	when using multiple databases, I did this below for each model.
#	Then I commented it all out!!! Err! Capybara is threaded and
#	testing is transactional so we must force them to use the
#	same connection or they will not see each others mods.
#	Original way or my way.  No matter.  But we must set the connection first.
#ActiveRecord::Base.saved_connection = ActiveRecord::Base.connection

#
#	back to the original ... ?
#
#	initially based on http://pastie.org/1745020, but has changed
#class ActiveRecord::Base
#	mattr_accessor :shared_connection
#	@@shared_connection = nil
#	def self.connection
#		@@shared_connection || retrieve_connection
#	end
#end
## Forces all threads to share the same connection. This works on
## Capybara because it starts the web server in a thread.
#ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection


#	I think that this oversteps its bounds and sets it in 
#	ALL tests, even functionals.  Doubt it
#class ApplicationController
#	def ssl_required?
#		false
#	end
#	def ssl_allowed?
#		true
#	end
#end

#	by creating separate subclasses, rather than just extending IntegrationTest, we can use both webrat and capybara
class ActionController::CapybaraIntegrationTest < ActionController::IntegrationTest

#	setup :do_not_force_ssl
	def do_not_force_ssl
		#	Forcing ssl is problematic in capybara unlike webrat, so I'm just skipping it.
		#	ApplicationController.subclasses does not initially include FakeSessionsController
		#	I explicitly 'ssl_allowed' new and create, so irrelevant.
		#	After the first request, it will be included though.

#		ApplicationController.any_instance.stubs(:ssl_required?).returns(false)
#		ApplicationController.any_instance.stubs(:ssl_allowed?).returns(true)

#
#	NOTE not sure which is better anymore
#

#		ApplicationController.subclasses.each do |controller|
##			controller.constantize.any_instance.stubs(:ssl_allowed?).returns(true) 
##	actually passes the class in Rails3 
#			controller.any_instance.stubs(:ssl_allowed?).returns(true) 
#		end

ApplicationController.class_eval do
	def ssl_required?
		false
	end
	def ssl_allowed?
		true
	end
end

	end

	setup :synchronize_selenium_connections	#	this includes :webkit
	def synchronize_selenium_connections
#		#	if driver is selenium based, need to synchronize the transactional connections
#		#
#		###	initially based on http://pastie.org/1745020, but has changed
#		#
#		#		class ActiveRecord::Base
#		#			mattr_accessor :shared_connection
#		#			@@shared_connection = nil
#		#			def self.connection
#		#				@@shared_connection || retrieve_connection
#		#			end
#		#		end
#		#		# Forces all threads to share the same connection. This works on
#		#		# Capybara because it starts the web server in a thread.
#		#		ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
#		#
#		###
#		#
#		#	connection hack for selenium
#		#	with selenium, the database connection from the test and from the controllers 
#		#		are different and as the connections are transactional, I think, the test 
#		#		will be unaware of changes that the controller makes and the controller 
#		#		will be unaware of changes that the test makes.  This seems to be why 
#		#		creating a user in the test does not result in a user being found in the 
#		#		controller.  The same goes for the user's roles.  It also means that the 
#		#		tests will not notice a difference after creating a page or other resource 
#		#		in the controller.  So.  Apparently, we need a hack in all the models that 
#		#		will do this. Normally, we could just hack AR::Base, but since we already 
#		#		have 2 connection (one for shared, one for the app), we can't (unless I 
#		#		find a new way)
#		#		So.  We need to individually hack any model that we may test.
#		#
#		#	I'd rather just loop through all the models, but there are a couple oddballs
#		#	from use_db that may cause issues.  Still polishing this one.
#		#	wonder what's gonna happen for modelless tables (roles_users)
#
#		#
#		#	Perhaps Shared.subclasses?
#		#
#		[Abstract,Address,Addressing,AddressType,
#			Aliquot,AliquotSampleFormat,Analysis,BcRequest,
#			CandidateControl,Context,
#			ContextDataSource,County,
#			DataSource,Diagnosis,DocumentType,DocumentVersion,Enrollment,
#			FollowUp,FollowUpType,GiftCard,Guide,
#			HomeExposureResponse,HomexOutcome,Hospital,
#			IcfMasterId,
#			IneligibleReason,Instrument,InstrumentType,InstrumentVersion,
#			Interview,InterviewMethod,InterviewOutcome,
#			Language,
#			OperationalEvent,OperationalEventType,Organization,Page,Patient,
#			PhoneNumber,PhoneType,Project,Person,ProjectOutcome,
#			Race,RefusalReason,Role,
#			Sample,SampleKit,SampleOutcome,SampleType,Section,StudySubject,
#			SubjectLanguage,Language,SubjectRace,SubjectRelationship,SubjectType,
#			Transfer,Unit,User,VitalStatus,ZipCode].each do |model|
#			model.saved_connection = model.connection
#		end
ActiveRecord::Base.saved_connection = ActiveRecord::Base.connection
	end

	include Capybara::DSL

	fixtures :all

	#	Special login_as for integration testing.
	def login_as( user=nil )
		uid = ( user.is_a?(User) ) ? user.uid : user
		if !uid.blank?
			stub_ucb_ldap_person()
			u = User.find_create_and_update_by_uid(uid)
			assert u.is_a?(User), "Created User isn't a User?"
			assert !u.new_record?, "Created user didn't save?"

			#	Rather than manually manipulate the session,
			#	I created a fake controller to do it.

#puts User.all.inspect


#	I don't quite understand what is happening, but now it seems as if the user doesn't logout
#	do I need to add a teardown :logout?


#CASClient::Frameworks::Rails::Filter.unstub(:filter)
#			page.visit logout_path

			page.visit new_fake_session_path()	#, { }, { 'HTTPS' => 'on' }
			assert_equal current_path, new_fake_session_path,
				"Didn't actually get new fake session path?"

#	It would seem that I accidentally created a "unique" index for :sn !!!!!
#	I don't completely see why it matters as they should be destroyed after
#	each test so there should never actually be more than one User.

#	This has got to be a connection thing

#<p>
#  Showing <i>app/views/layouts/_header.html.erb</i> where line <b>#8</b> raised:
#  </p><pre><code>Mysql::Error: Duplicate entry 'Wendt' for key 2: UPDATE `users` SET `updated_at` = '2012-03-14 05:11:15', `sn` = 'Wendt', `telephonenumber` = '+1 510 642-9749', `displayname` = 'Mr. Jake Wendt, BA' WHERE `id` = 5148</code></pre>
#<p></p>
#

#puts page.body
			assert page.has_field?('id'),
				"id field not found.  Probably didn't actually load new session page."

			#Capybara::ElementNotFound: cannot fill in, no text field, text area or password field with id, name, or label 'id' found
			page.fill_in 'id', :with => u.id

			page.click_button 'login'

			#	assert that there is a user logged in			
			assert_equal current_path, user_path(u),
				"Login_as seems to have failed." 
		end
	end

#	common methods ( consent and nonwaivered both use languages )

	def language_input_id(language,field='language_id')
		#	[2] since 'other' will be the third language in the array
#		case language
#			when 'english'
#				"study_subject_subject_languages_attributes_0_#{field}"	#	english
#			when 'spanish'
#				"study_subject_subject_languages_attributes_1_#{field}"	#	spanish
#			when 'other'
#				"study_subject_subject_languages_attributes_2_#{field}"	#	other
#		end
		"#{language}_#{field}"
	end

	def language_input_css_id(language,field='language_id')
		"##{language_input_id(language,field)}"
	end

	def assert_page_has_unchecked_language_id(language)
		assert page.has_unchecked_field?(language_input_id(language))
	end

	def assert_page_has_checked_language_id(language)
		assert page.has_checked_field?(language_input_id(language))
	end

	def assert_page_has_unchecked_language_destroy(language)
		assert page.has_unchecked_field?(language_input_id(language,'_destroy'))
	end

	def assert_page_has_checked_language_destroy(language)
		assert page.has_checked_field?(language_input_id(language,'_destroy'))
	end

	def assert_other_language_visible
		assert page.has_css?("#specify_other_language", :visible => true)
#		assert page.has_css?(language_input_css_id('other','other'),:visible => true)
#		assert page.has_field?(language_input_id('other','other'))
#		assert page.find_field(language_input_id('other','other')).visible?
		assert page.has_css?(language_input_css_id('other','other_language'),:visible => true)
		assert page.has_field?(language_input_id('other','other_language'))
		assert page.find_field(language_input_id('other','other_language')).visible?
	end

	def assert_other_language_hidden
		assert page.has_css?("#specify_other_language", :visible => false)
#		assert page.has_css?(language_input_css_id('other','other'),:visible => false)
#		assert !page.find_field(language_input_id('other','other')).visible?
		assert page.has_css?(language_input_css_id('other','other_language'),:visible => false)
		assert !page.find_field(language_input_id('other','other_language')).visible?
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
