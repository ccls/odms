source 'https://rubygems.org'

gem 'bundler'



#	try removing minitest
#
#	I think that this is needed because of CommonLib
#	it load ActiveSupport::TestCase which loads its dependencies.
#	See if can only do this in test environment.
#


gem 'jakewendt-active_record_sunspotter'
#	copied in sunspot_rails-2.1.0/lib/sunspot/rails/adapters.rb
#	to stop ActiveRecord deprecation warnings
#	Commented that out now.




#	minitest-5.3.4/lib/minitest.rb
#	still true in 5.4.0.  May need to just redefine the offending method.
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

gem 'rails'
gem 'protected_attributes'	#	to keep rails 3 style
#gem 'activerecord-session_store'	#	to keep rails 3 style	... going back to cookies so removed

gem 'json'

gem 'sass'
# Use SCSS for stylesheets
gem 'sass-rails'	#, '~> 4.0'

gem 'rack-ssl', :require => 'rack/ssl'

gem "mysql"
gem "mysql2"
gem "RedCloth"

gem "chronic"

gem "acts_as_list"

#	added a patch to deal with counting when select is provided based on ....
#	https://github.com/mislav/will_paginate/pull/348
#	3.0.7 seems to have fixed this.  Patch actually breaks stuff so commented out for now.
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
	gem 'rails-dom-testing'
	gem 'test-unit'
	gem "simplecov", :require => false

	#	for dealing with integration tests
	gem 'database_cleaner'

	gem "mocha", :require => 'mocha/setup'

	gem "autotest-rails", :require => 'autotest/rails'
#	gem "redgreen"

	gem 'ZenTest'

	gem "factory_girl_rails"

	gem 'jakewendt-html_test'

	gem 'capybara'
	gem 'capybara-webkit'

	gem 'jakewendt-test_with_verbosity'
end

gem 'ccls-common_lib', ">0.9"


#	1.1.9 will raise error ...
#	use_ssl value changed, but session already started
#	geocoder-1.1.9/lib/geocoder/lookups/base.rb line 230ish
#	WHERE? WHEN? rake task? testing? ... "bundle exec rake app:addresses:geocode"
#	1.2.1 is working so far
gem 'geocoder'

__END__
