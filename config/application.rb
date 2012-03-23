require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
	# If you precompile assets before deploying to production, use this line
	Bundler.require(*Rails.groups(:assets => %w(development test)))
	# If you want your assets lazily compiled in production, use this line
	# Bundler.require(:default, :assets, Rails.env)
end

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

		# Configure the default encoding used in templates for Ruby 1.9.
		config.encoding = "utf-8"

		# Configure sensitive parameters which will be filtered from the log file.
		config.filter_parameters += [:password]

		# Use SQL instead of Active Record's schema dumper when creating the database.
		# This is necessary if your schema can't be completely dumped by the schema dumper,
		# like if you have constraints or database-specific column types
		# config.active_record.schema_format = :sql

		# Enforce whitelist mode for mass assignment.
		# This will create an empty whitelist of attributes available for mass-assignment for all models
		# in your app. As such, your models will need to explicitly whitelist or blacklist accessible
		# parameters by using an attr_accessible or attr_protected declaration.
		# config.active_record.whitelist_attributes = true





#	Don't know exactly what this is about, but it looks for assets
#	in non-Rails2 places. Don't want to deal with this now.
		# Enable the asset pipeline
		config.assets.enabled = true

#	enabled asset pipeline
#	HOWEVER, now, for whatever reason, all of my expected 
#		ActionController::RoutingError tests fail as the routes
#		exists?  I'm confused as to why that should happen.
#		And its not like the request is sent to some assets controller
#		or even my pages controller catch.  It goes to the
#		associated controller!!!!
#	Fortunately, this does not appear to be the case in reality.
#	Non-existant routes are still non-existant, but not in testing




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
		config.assets.version = '1.0'
	end
end



require 'hpricot'
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| 
	error_class = 'field_error'
	nodes = Hpricot(html_tag)
	nodes.each_child { |node| 
		node[:class] = node.classes.push(error_class).join(' ') unless !node.elem? || node[:type] == 'hidden' || node.classes.include?(error_class) 
	}
	nodes.to_html.html_safe
}

