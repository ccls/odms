# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

config.gem "rcov"

#	Without the :lib => false, the 'rake test' actually fails?
config.gem "mocha", :lib => false

config.gem "autotest-rails", :lib => 'autotest/rails'

config.gem "ZenTest"

config.gem "thoughtbot-factory_girl",
	:lib    => "factory_girl",
	:source => "http://gems.github.com"

config.gem 'ccls-html_test'

config.action_mailer.default_url_options = { 
	:host => "dev.sph.berkeley.edu:3000" }

config.gem 'webrat'
config.gem 'capybara'
config.gem 'capybara-webkit'

#
#	Modifications to add FakeSessionsController solely for integration testing
#
ActionController::Routing::Routes.add_configuration_file(
	File.expand_path( File.join( Rails.root, '/test/config/routes.rb')))

ActiveSupport::Dependencies.autoload_paths << File.expand_path( 
	File.join(Rails.root,'/test/app/controllers/'))

ActionController::Base.view_paths <<
	File.expand_path(
		File.join(Rails.root,'/app/views'))
ActionController::Base.view_paths <<
	File.expand_path(
		File.join(Rails.root,'/test/app/views'))


#	Had to use active_record_store to accomodate ActiveScaffold,
#	but apparently my capybara integration tests do not like this.
#	So, set the session_store back to the default of cookies
#	just for testing.  At least until I figure out how to make
#	it work.
config.action_controller.session_store = :cookie_store

