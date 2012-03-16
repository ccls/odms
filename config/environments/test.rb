Odms::Application.configure do
	# Settings specified here will take precedence over those in config/application.rb

	# The test environment is used exclusively to run your application's
	# test suite. You never need to work with it otherwise. Remember that
	# your test database is "scratch space" for the test suite and is wiped
	# and recreated between test runs. Don't rely on the data there!
	config.cache_classes = true

	# Configure static asset server for tests with Cache-Control for performance
	config.serve_static_assets = true
	config.static_cache_control = "public, max-age=3600"

	# Log error messages when you accidentally call methods on nil
	config.whiny_nils = true

	# Show full error reports and disable caching
	config.consider_all_requests_local			 = true
	config.action_controller.perform_caching = false

	# Raise exceptions instead of rendering exception templates
	config.action_dispatch.show_exceptions = false

	# Disable request forgery protection in test environment
	config.action_controller.allow_forgery_protection		= false

	# Tell Action Mailer not to deliver emails to the real world.
	# The :test delivery method accumulates sent emails in the
	# ActionMailer::Base.deliveries array.
	config.action_mailer.delivery_method = :test

	# Raise exception on mass assignment protection for Active Record models
	config.active_record.mass_assignment_sanitizer = :strict

	# Print deprecation notices to the stderr
	config.active_support.deprecation = :stderr




#	Don't mail so irrelevant.

	config.action_mailer.default_url_options = { 
		:host => "dev.sph.berkeley.edu:3000" }

##
##	Modifications to add FakeSessionsController solely for integration testing
##
#ActionController::Routing::Routes.add_configuration_file(
#	File.expand_path( File.join( Rails.root, '/test/config/routes.rb')))
#
#ActiveSupport::Dependencies.autoload_paths << File.expand_path( 
#	File.join(Rails.root,'/test/app/controllers/'))
#
#ActionController::Base.view_paths <<
#	File.expand_path(
#		File.join(Rails.root,'/app/views'))
#ActionController::Base.view_paths <<
#	File.expand_path(
#		File.join(Rails.root,'/test/app/views'))


#	Had to use active_record_store to accomodate ActiveScaffold,
#	but apparently my capybara integration tests do not like this.
#	So, set the session_store back to the default of cookies
#	just for testing.  At least until I figure out how to make
#	it work. I think that I just need a bigger hammer.
#config.action_controller.session_store = :cookie_store

	config.session_store :cookie_store, :key => '_odms_session'

end
