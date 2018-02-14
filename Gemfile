source 'https://rubygems.org'

gem 'bundler'

gem 'passenger'



#	try removing minitest
#
#	I think that this is needed because of CommonLib
#	it load ActiveSupport::TestCase which loads its dependencies.
#	See if can only do this in test environment.
#

#	1.0.11 generates a lot of 
#	[DEPRECATION] `RSolr.escape` is deprecated (and incorrect).  Use `Rsolr.solr_escape` instead.
gem 'rsolr', '<1.0.11'

gem 'jakewendt-active_record_sunspotter'
gem 'sunspot', '=2.1.1'
gem 'sunspot_rails', '=2.1.1'
gem 'sunspot_solr', '=2.1.1'
#	upgraded to 2.2.0 and got lots of ...
#	NoMethodError: undefined method `solr_escape' for RSolr:Module

#	copied in sunspot_rails-2.1.0/lib/sunspot/rails/adapters.rb
#	to stop ActiveRecord deprecation warnings
#	Commented that out now.




#	minitest-5.3.4/lib/minitest.rb
#	still true in 5.4.0.  May need to just redefine the offending method.
#	test classes are purposely shuffled!  Only change in this version!  Why?
#	Random is stupid.  Unpredictable.  Poor testing strategy.
#	144: suites = Runnable.runnables.shuffle
#	remove this requirement if can find a way around
#	still true in 5.5.0
gem 'minitest', '= 5.3.3'

#	PDF generation
gem 'prawn'
gem 'prawnto'

#	ruby 1.9.3 requirement to parse american date
#	format Month/Day/Year Date.parse('12/31/2000')
gem 'american_date'

gem 'rails', '~>4'

gem 'json'

gem 'sass'
# Use SCSS for stylesheets
gem 'sass-rails'

gem 'rack-ssl', :require => 'rack/ssl'

gem "mysql"
gem "mysql2"
gem "RedCloth"

gem "chronic"

gem "acts_as_list"

gem "will_paginate"

gem "hpricot"

gem 'rubycas-client'

#	ucb_ldap required modification and is now included in the app
#gem 'ucb_ldap'
#	ucb_ldap appears to have been upgraded, but needs --pre option.  How?
gem 'ucb_ldap', "~> 2.0.0.pre"
#	usage of the new ucb_ldap gem downgrades the net-ldap gem.
gem 'net-ldap'


group :test do

	gem 'rails-dom-testing'	#	for assert_select

	gem 'test-unit'

	gem "simplecov", :require => false	#	for coverage testing

	#	for dealing with integration tests
	gem 'database_cleaner'

	gem "mocha", :require => 'mocha/setup'

	gem "autotest-rails", :require => 'autotest/rails'
#	gem "redgreen"	#	never seems to work

	gem 'ZenTest'

	gem "factory_bot_rails"

	gem 'jakewendt-html_test'

	gem 'capybara'
#	gem 'capybara-webkit', '~>1.6.0'	#	will require qt4-mac
	gem 'capybara-webkit'	#	=> 1.7 will require qt5-mac

	gem 'jakewendt-test_with_verbosity'
end

gem 'ccls-common_lib', ">0.9"

gem 'geocoder'


gem 'ffi', '1.9.18'

__END__

