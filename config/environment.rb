# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

#ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#	This constant is used in the ccls_engine#Document
#	and other places like Amazon buckets
#	for controlling the path to documents.
RAILS_APP_NAME = 'odms'

Rails::Initializer.run do |config|

	#	active_record_store needed to accomodate the cookie
	#	excess created by ActiveScaffold.  Integration testing does 
	#	not like this, so it is set back to cookie_store for testing.
	#	Should we abandon the usage of ActiveScaffold, we can, but 
	#	don't have to, switch back to the default.
	config.action_controller.session_store = :active_record_store

	config.gem 'ssl_requirement'
	config.gem 'mysql'

	config.gem 'jrails'

	config.gem 'ryanb-acts-as-list', :lib => 'acts_as_list'
	config.gem 'will_paginate'
	config.gem 'fastercsv'
	config.gem 'hpricot'
	config.gem 'paperclip', '=2.4.2'

	config.gem 'rubycas-client', '>= 2.2.1'

#	This used to be required in the application controller?
#require 'casclient'
#require 'casclient/frameworks/rails/filter'

	config.gem 'ucb_ldap', '>= 1.4.2'

	config.frameworks -= [ :active_resource ]

	# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
	# Run "rake -D time" for a list of tasks for finding time zone names.
	config.time_zone = 'Pacific Time (US & Canada)'

end

#	don't use the default div wrappers as they muck up style
#	just adding a class to the tag is a little better
require 'hpricot'
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| 
	error_class = 'field_error'
	nodes = Hpricot(html_tag)
	nodes.each_child { |node| 
		node[:class] = node.classes.push(error_class).join(' ') unless !node.elem? || node[:type] == 'hidden' || node.classes.include?(error_class) 
	}
	nodes.to_html
}



##	methods or constants?
#def valid_sex_values
#	%w( M F DK )
#end


#ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion( 
#	:ccls => ['scaffold','ccls_engine','application'] )
#ActionView::Helpers::AssetTagHelper.register_javascript_expansion( 
#	:ccls => ['jquery','jquery-ui','jrails','application'] )




HTML::WhiteListSanitizer.allowed_attributes.merge(%w(
	id class style
))

