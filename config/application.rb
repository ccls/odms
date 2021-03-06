require File.expand_path('../boot', __FILE__)

require 'rails/all'

#if defined?(Bundler)
#	# If you precompile assets before deploying to production, use this line
##	Bundler.require(*Rails.groups(:assets => %w(development test)))
#	Bundler.require(:default,Rails.env)
#	# If you want your assets lazily compiled in production, use this line
#	# Bundler.require(:default, :assets, Rails.env)
#end
#	20150320 - rake rails:update
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Odms
	class Application < Rails::Application
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.

		# Custom directories with classes and modules you want to be autoloadable.
		# config.autoload_paths += %W(#{config.root}/extras)

		# Only load the plugins named here, in the order given (default is alphabetical).
		# :all can be used as a placeholder for all plugins not explicitly named.
		# config.plugins = [ :exception_notification, :ssl_requirement, :all ]

		# Activate observers that should always be running.
		# config.active_record.observers = :cacher, :garbage_collector, :forum_observer

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
		# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		# config.time_zone = 'Central Time (US & Canada)'
		config.time_zone = 'Pacific Time (US & Canada)'

		# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
		# config.i18n.default_locale = :de


		#	In order to silence this internal rails warning ...
		#		[deprecated] I18n.enforce_available_locales will default to true in the future.
		#			If you really want to skip validation of your locale you can set
		#			I18n.enforce_available_locales = false to avoid this message.
		#	explicitly add this line
		config.i18n.enforce_available_locales = true
		#	If setting default_locale, the previous line MUST come first.
		config.i18n.default_locale = :en


		# Configure the default encoding used in templates for Ruby 1.9.
		config.encoding = "utf-8"

		# Configure sensitive parameters which will be filtered from the log file.
		#	20150320 - rake rails:update (moved to own file)
		#config.filter_parameters += [:password]

		# Use SQL instead of Active Record's schema dumper when creating the database.
		# This is necessary if your schema can't be completely dumped by the schema dumper,
		# like if you have constraints or database-specific column types
		# config.active_record.schema_format = :sql

		# Enforce whitelist mode for mass assignment.
		# This will create an empty whitelist of attributes available for mass-assignment for all models
		# in your app. As such, your models will need to explicitly whitelist or blacklist accessible
		# parameters by using an attr_accessible or attr_protected declaration.
		# config.active_record.whitelist_attributes = true

		# Enable the asset pipeline
		config.assets.enabled = true

#
#	Dealing with SSL/HTTPS is being dealt with on the web server level
#	Even when enabled, ssl seems to be ignored during testing and development
#		as the browser and the server are the same machine?
#
#		config.force_ssl = true
#railties-3.2.2/lib/rails/application.rb
#238         if config.force_ssl
#239           require "rack/ssl"
#240           middleware.use ::Rack::SSL, config.ssl_options
#241         end
#

#	In Rails3, json does not include the root key by default.
#	Could set it to true, but have already dealt with
#	this missing key.
#
#	config.active_record.include_root_in_json = true



		# Version of your assets, change this if you want to expire all your assets
		#config.assets.version = '1.0'

#	I followed instructions to secrets.yml, but app doesn't actually read it?
#	I will probably have to removing the following line when 4.1 is used.
#	http://stackoverflow.com/questions/21136363/using-config-secrets-yml-in-rails-4-0-2-version
#	https://github.com/rails/rails/pull/13298

#	20150320 - I shouldn't need this line
#config.secret_key_base = YAML.load(File.open("#{Rails.root}/config/secrets.yml"))[Rails.env]['secret_key_base']




		#	20150320 - rails 4.1.10
		# Do not swallow errors in after_commit/after_rollback callbacks.
#	fails in testing?
#		config.active_record.raise_in_transactional_callbacks = true




		#	20160418
		#	DEPRECATION WARNING: Currently, Active Record suppresses errors raised within `after_rollback`/`after_commit` callbacks and only print them to the logs. In the next version, these errors will no longer be suppressed. Instead, the errors will propagate normally just like in other Active Record callbacks.
		#	You can opt into the new behavior and remove this warning by setting:
		#
		config.active_record.raise_in_transactional_callbacks = true
		#
		#	This seems to be inspired by "acts_as_list" calls
		#

	end
end
