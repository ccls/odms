#Odms::Application.configure do
#	20150320 - rake rails:update
Rails.application.configure do
	# Settings specified here will take precedence over those in config/application.rb

	# In the development environment your application's code is reloaded on
	# every request. This slows down response time but is perfect for development
	# since you don't have to restart the web server when you make code changes.
	config.cache_classes = false

	# Log error messages when you accidentally call methods on nil.
#	config.whiny_nils = true

	# Show full error reports and disable caching
	config.consider_all_requests_local			 = true
	config.action_controller.perform_caching = false



	# Tell Action Mailer not to deliver emails to the real world.
	# The :test delivery method accumulates sent emails in the
	# ActionMailer::Base.deliveries array.
	config.action_mailer.delivery_method = :test




	# Don't care if the mailer can't send
	config.action_mailer.raise_delivery_errors = false

	# Print deprecation notices to the Rails logger
	config.active_support.deprecation = :log

	#	20150320 - rake rails:update
	# Raise an error on page load if there are pending migrations.
	config.active_record.migration_error = :page_load

	# Only use best-standards-support built into browsers
#	config.action_dispatch.best_standards_support = :builtin

	# Raise exception on mass assignment protection for Active Record models
#	config.active_record.mass_assignment_sanitizer = :strict

	# Log the query plan for queries taking more than this (works
	# with SQLite, MySQL, and PostgreSQL)
#
#	This is really irritating.  Any query that takes longer than this
#	will raise the following error and stopping everything.
#		undefined method `explain' for #<ActiveRecord::ConnectionAdapters::MysqlAdapter
#	The error apparently comes from the common mysql adapter 
#	NOT having an explain method.  Some recommend installing
#	the mysql2 adapter. Commenting out for now.
#
#	ZipCode.destroy_all or others will take more than 0.5 seconds.
#
#	config.active_record.auto_explain_threshold_in_seconds = 0.5

	# Do not compress assets
	config.assets.compress = false

	# Debug mode disables concatenation and preprocessing of assets.
	# This option may cause significant delays in view rendering with a large
	# number of complex assets.
	# Expands the lines which load the assets
	config.assets.debug = true

	#	20150320 - rake rails:update
	# Adds additional error checking when serving assets at runtime.
	# Checks for improperly declared sprockets dependencies.
	# Raises helpful error messages.
	config.assets.raise_runtime_errors = true





	config.action_mailer.delivery_method = :smtp

	config.action_mailer.default_url_options = { 
		:protocol => "https",
		:host => "dev.sph.berkeley.edu" }

	config.eager_load = false

	#	20150320 - rake rails:update
	# Raises error for missing translations
	# config.action_view.raise_on_missing_translations = true
end
