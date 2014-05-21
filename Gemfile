source 'https://rubygems.org'

gem 'bundler'



#	try upgrading capybara
#	try upgrading mocha?

#	try removing minitest
#
#	I think that this is needed because of CommonLib
#	it load ActiveSupport::TestCase which loads its dependencies.
#	See if can only do this in test environment.
#


gem 'jakewendt-active_record_sunspotter'
#	copied in sunspot_rails-2.1.0/lib/sunspot/rails/adapters.rb
#	to stop ActiveRecord deprecation warnings




#	minitest-5.3.4/lib/minitest.rb
#	test classes are purposely shuffled!  Only change in this version!  Why?
#	Random is stupid.  Unpredictable.  Poor testing strategy.
#	144: suites = Runnable.runnables.shuffle
#	remove this requirement if can find a way around
gem 'minitest', '= 5.3.3'

#	PDF generation
gem 'prawn'
gem 'prawnto'

#	ruby 1.9.3 requirement to parse american date
#	format Month/Day/Year Date.parse('12/31/2000')
gem 'american_date'

gem 'rails', '~> 4'
gem 'protected_attributes'	#	to keep rails 3 style
#gem 'activerecord-session_store'	#	to keep rails 3 style

gem 'json'

gem 'sass'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0'

gem 'rack-ssl', :require => 'rack/ssl'

gem "mysql"
gem "mysql2"
gem "RedCloth"

gem "chronic"

gem "acts_as_list"

#	added a patch to deal with counting when select is provided based on ....
#	https://github.com/mislav/will_paginate/pull/348
gem "will_paginate"

gem "hpricot"

gem 'rubycas-client'

#	ucb_ldap required modification and is now included in the app
#gem 'ucb_ldap'
#	ucb_ldap appears to have been upgraded, but needs --pre option.  How?
gem 'ucb_ldap', "~> 2.0.0.pre"
#	usage of the new ucb_ldap gem downgrades the net-ldap gem.
gem 'net-ldap'

#gem "mongrel"	#	not install in ruby19 world
#	suggested to use --pre option for 1.2.0

group :test do
	gem 'test-unit'
	gem "simplecov", :require => false

	#	for dealing with integration tests
	gem 'database_cleaner'

	gem "mocha", :require => false

	gem "autotest-rails", :require => 'autotest/rails'
#	gem "redgreen"

	gem 'ZenTest'

	gem "factory_girl_rails"

	gem 'jakewendt-html_test'

	#	the latest capybara seems to install just fine when the latest xcode and command line tools are.
	#	NOTE however, the "find field" seems to always fail?
	#
	#	newer capybara not compatible with current webkit
	#	need to explicitly have capybara for the version or
	#	it will by upgraded to 2.1.0 which fails
	gem 'capybara', '~> 2.0.0'
	#	capybara-webkit 1.0.0 bombs big time compiling native code
	gem 'capybara-webkit', '~> 0.14'

	#	After rails 4, upgraded capybara stuff, but still had issues finding fields
	#	capybara (2.2.1)
	#	capybara-webkit (1.1.0)

	gem 'jakewendt-test_with_verbosity'
end

gem 'jakewendt-active_record_left_joins'

gem 'ccls-common_lib', ">0.9"


#	1.1.9 will raise error ...
#	use_ssl value changed, but session already started
#	geocoder-1.1.9/lib/geocoder/lookups/base.rb line 230ish
#	WHERE? WHEN? rake task? testing? 
#	1.2.1 is working so far
gem 'geocoder'	#, "=1.1.8"

__END__
