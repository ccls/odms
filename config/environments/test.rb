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





#	TODO uncomment this.  For now, I have more pressing things to deal with.

	# Raise exception on mass assignment protection for Active Record models
#	config.active_record.mass_assignment_sanitizer = :strict






	# Print deprecation notices to the stderr
	config.active_support.deprecation = :stderr




#	Don't mail so irrelevant.
#
#	config.action_mailer.default_url_options = { 
#		:host => "dev.sph.berkeley.edu:3000" }
#


#	Had to use active_record_store to accomodate ActiveScaffold,
#	but apparently my capybara integration tests do not like this.
#	So, set the session_store back to the default of cookies
#	just for testing.	At least until I figure out how to make
#	it work. I think that I just need a bigger hammer.
#config.action_controller.session_store = :cookie_store

	config.session_store :cookie_store, :key => '_odms_session'



#	are these arrays??
#	can't tell if this is doing what I want.
#	tried it in console and it seems to.

#	What's the point of exposing an array that is frozen????
#	config.autoload_paths << File.join(Rails.root, "test/app/controllers/")
# => /Users/jakewendt/github_repo/ccls/odms/config/environments/test.rb:72:in `<<': can't modify frozen array (TypeError)

#	This works, but I assume will break everything else.
#	config.autoload_paths = File.join(Rails.root, "test/app/controllers/")

#	config.autoload_paths += File.join(Rails.root, "test/app/controllers/")
# => /Users/jakewendt/github_repo/ccls/odms/config/environments/test.rb:77:in `+': can't convert String into Array (TypeError)
# 19     # config.autoload_paths += %W(#{config.root}/extras)
#	This seems to work for the moment
	config.autoload_paths += %W(#{config.root}/test/app/controllers/")

#	config.paths["app/controllers"] << File.join(Rails.root, "test/app/controllers/") 



	config.paths["app/views"] << File.join(Rails.root, "test/app/views/") 

	#	This seems to work, but still doesn't show up.
#	config.paths["config/routes"] << File.join(Rails.root, "test/config/routes.rb") 
	config.paths["config/routes"] += %W(#{config.root}/test/config/routes.rb)

end
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
#
