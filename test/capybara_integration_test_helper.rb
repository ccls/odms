
#	Changing to use capybara from webrat in hopes of testing javascript.

require 'capybara/rails'

Capybara.default_driver = :selenium
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
Selenium::WebDriver::Firefox::Binary.path='/Applications/Firefox.app/Contents/MacOS/firefox-bin-leopard-dittod'
Capybara.register_driver :selenium_firefox do |app|
	Capybara::Selenium::Driver.new(app, :browser => :firefox)
end


#	for selenium only, I think, as it does not cleanup
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.start



#	connection hack for selenium
#	CANNOT do this for AR::Base as already have 2 databases

#class ActiveRecord::Base
#class ('User'.constantize)
#User.extend do
#klass.constantize.class_eval do
module MakeConnectionTheSame
  mattr_accessor :shared_connection
  @@shared_connection = nil

#  def self.connection
  def connection
    @@shared_connection || retrieve_connection
  end
end
#%w( User ).each do |klass|
# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
#ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
User.extend MakeConnectionTheSame
User.shared_connection = User.connection
Role.extend MakeConnectionTheSame
Role.shared_connection = Role.connection
Page.extend MakeConnectionTheSame
Page.shared_connection = Page.connection
#klass.constantize.send(:extend,MakeConnectionTheSame)
#klass.constantize.shared_connection = klass.constantize.connection
#end





#	fake all non-ssl JUST ON JAKE'S HOME MACBOOK as no ssl installed
#	add condition to this so that it only runs there.
class ApplicationController
	def ssl_allowed?
		true
	end
end	if( Socket.gethostname == "mbp-3.local" )
#> Socket.gethostname
#=> "mbp-3.local"



#	by creating separate subclasses, rather than just extending IntegrationTest, we can use both webrat and capybara
class ActionController::CapybaraIntegrationTest < ActionController::IntegrationTest
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
#puts "Before find:#{User.all.inspect}"
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
#puts "Before new:#{User.all.inspect}"
			page.visit new_fake_session_path()	#, { }, { 'HTTPS' => 'on' }
#puts "After new:#{User.all.inspect}"
#puts page.body

#	in rack_test, the connections are the same
#in controller connection check
#<ActiveRecord::ConnectionAdapters::MysqlAdapter:0x3c99bec @query_cache_enabled=true, @query_cache={"SELECT * FROM `guides` WHERE (`guides`.`controller` = 'fake_sessions' AND `guides`.`action` = 'create')  ORDER BY controller ASC, action ASC LIMIT 1"=>[]}, @transaction_joinable=false, @quoted_column_names={"name"=>"`name`", "menu_en"=>"`menu_en`", "position"=>"`position`", :path=>"`path`", "created_at"=>"`created_at`", "guides"=>"`guides`", "displayname"=>"`displayname`", "body_es"=>"`body_es`", "body"=>"`body`", "title_es"=>"`title_es`", "updated_at"=>"`updated_at`", "role_id"=>"`role_id`", "action"=>"`action`", "mail"=>"`mail`", "sn"=>"`sn`", "uid"=>"`uid`", :uid=>"`uid`", "menu_es"=>"`menu_es`", "id"=>"`id`", "user_id"=>"`user_id`", "telephonenumber"=>"`telephonenumber`", "pages"=>"`pages`", "parent_id"=>"`parent_id`", "path"=>"`path`", :menu_en=>"`menu_en`", "roles_users"=>"`roles_users`", "users"=>"`users`", "body_en"=>"`body_en`", "hide_menu"=>"`hide_menu`", "controller"=>"`controller`", "title_en"=>"`title_en`", "roles"=>"`roles`"}, @last_verification=0, @connection_options=["localhost", "root", "", "odms_test", nil, nil, 131072], @logger=#<ActiveSupport::BufferedLogger:0x419718 @log=#<File:/Users/jake/github_repo/ccls/odms/log/test.log>, @guard=#<Mutex:0x4093e0>, @level=0, @auto_flushing=1, @buffer={}>, @open_transactions=1, @runtime=0.386953353881836, @config={:password=>nil, :database=>"odms_test", :host=>"localhost", :encoding=>"utf8", :adapter=>"mysql", :username=>"root"}, @quoted_table_names={"guides"=>"`guides`", "pages"=>"`pages`", "roles_users"=>"`roles_users`", "users"=>"`users`", "roles"=>"`roles`"}, @connection=#<Mysql:0x3c9a718>>
#in test connection check
#<ActiveRecord::ConnectionAdapters::MysqlAdapter:0x3c99bec @query_cache_enabled=false, @query_cache={}, @transaction_joinable=false, @quoted_column_names={"name"=>"`name`", "menu_en"=>"`menu_en`", "position"=>"`position`", :path=>"`path`", "created_at"=>"`created_at`", "guides"=>"`guides`", "displayname"=>"`displayname`", "body_es"=>"`body_es`", "body"=>"`body`", "title_es"=>"`title_es`", "updated_at"=>"`updated_at`", "role_id"=>"`role_id`", "action"=>"`action`", "mail"=>"`mail`", "sn"=>"`sn`", "uid"=>"`uid`", :uid=>"`uid`", "menu_es"=>"`menu_es`", "id"=>"`id`", "user_id"=>"`user_id`", "telephonenumber"=>"`telephonenumber`", "pages"=>"`pages`", "parent_id"=>"`parent_id`", "path"=>"`path`", :menu_en=>"`menu_en`", "roles_users"=>"`roles_users`", "users"=>"`users`", "body_en"=>"`body_en`", "hide_menu"=>"`hide_menu`", "controller"=>"`controller`", "title_en"=>"`title_en`", "roles"=>"`roles`"}, @last_verification=0, @connection_options=["localhost", "root", "", "odms_test", nil, nil, 131072], @logger=#<ActiveSupport::BufferedLogger:0x419718 @log=#<File:/Users/jake/github_repo/ccls/odms/log/test.log>, @guard=#<Mutex:0x4093e0>, @level=0, @auto_flushing=1, @buffer={}>, @open_transactions=1, @runtime=0, @config={:password=>nil, :database=>"odms_test", :host=>"localhost", :encoding=>"utf8", :adapter=>"mysql", :username=>"root"}, @quoted_table_names={"guides"=>"`guides`", "pages"=>"`pages`", "roles_users"=>"`roles_users`", "users"=>"`users`", "roles"=>"`roles`"}, @connection=#<Mysql:0x3c9a718>>


#	in selenium, the connections are different.  WHY????? has something to do with Threads and as testing, inside transaction ?
#in controller connection check
#<ActiveRecord::ConnectionAdapters::MysqlAdapter:0x3ebd018 @query_cache_enabled=true, @query_cache={"SELECT * FROM `guides` WHERE (`guides`.`controller` = 'fake_sessions' AND `guides`.`action` = 'create')  ORDER BY controller ASC, action ASC LIMIT 1"=>[]}, @quoted_column_names={"guides"=>"`guides`", "action"=>"`action`", "pages"=>"`pages`", "path"=>"`path`", "controller"=>"`controller`"}, @last_verification=0, @connection_options=["localhost", "root", "", "odms_test", nil, nil, 131072], @logger=#<ActiveSupport::BufferedLogger:0x419718 @log=#<File:/Users/jake/github_repo/ccls/odms/log/test.log>, @guard=#<Mutex:0x4093e0>, @level=0, @auto_flushing=1, @buffer={}>, @runtime=0.366926193237305, @config={:password=>nil, :database=>"odms_test", :host=>"localhost", :encoding=>"utf8", :adapter=>"mysql", :username=>"root"}, @quoted_table_names={"guides"=>"`guides`", "pages"=>"`pages`"}, @connection=#<Mysql:0x3ebf1ec>>
#in test connection check
#<ActiveRecord::ConnectionAdapters::MysqlAdapter:0x3c99c50 @query_cache_enabled=false, @transaction_joinable=false, @quoted_column_names={"name"=>"`name`", "menu_en"=>"`menu_en`", "position"=>"`position`", "created_at"=>"`created_at`", "guides"=>"`guides`", "displayname"=>"`displayname`", "body_es"=>"`body_es`", "body"=>"`body`", "title_es"=>"`title_es`", "updated_at"=>"`updated_at`", "role_id"=>"`role_id`", "action"=>"`action`", "mail"=>"`mail`", "sn"=>"`sn`", "uid"=>"`uid`", :uid=>"`uid`", "menu_es"=>"`menu_es`", "id"=>"`id`", "user_id"=>"`user_id`", "telephonenumber"=>"`telephonenumber`", "pages"=>"`pages`", "parent_id"=>"`parent_id`", "path"=>"`path`", "roles_users"=>"`roles_users`", "users"=>"`users`", "body_en"=>"`body_en`", "hide_menu"=>"`hide_menu`", "controller"=>"`controller`", "title_en"=>"`title_en`", "roles"=>"`roles`"}, @last_verification=0, @connection_options=["localhost", "root", "", "odms_test", nil, nil, 131072], @logger=#<ActiveSupport::BufferedLogger:0x419718 @log=#<File:/Users/jake/github_repo/ccls/odms/log/test.log>, @guard=#<Mutex:0x4093e0>, @level=0, @auto_flushing=1, @buffer={}>, @open_transactions=1, @runtime=369.238138198853, @config={:password=>nil, :database=>"odms_test", :host=>"localhost", :encoding=>"utf8", :adapter=>"mysql", :username=>"root"}, @quoted_table_names={"guides"=>"`guides`", "pages"=>"`pages`", "roles_users"=>"`roles_users`", "users"=>"`users`", "roles"=>"`roles`"}, @connection=#<Mysql:0x3c9a77c>>


#	while this fixes the fake login, later a view calls 'logged_in?' which calls current_user
#		which tries for find user and then fails.  Its almost like its using a different database.
#		It ends up timing out??
			page.fill_in 'id', :with => u.id
#			page.fill_in 'uid', :with => u.uid


			#	MUST stub BEFORE login as redirect will got to users#show which will require being logged in.
			#	moved into fake_sessions controller
#			CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)

#puts "After fill in:#{User.all.inspect}"
			page.click_button 'login'
#puts "After submit:#{User.all.inspect}"
#	even though the user does exist, the fake session controller cannot find User.find(u.id) in create???
#	but ONLY when using selenium?  Don't quite understand this.
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
