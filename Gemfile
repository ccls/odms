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


#	20140117 - Stick with java 1.6.  java 1.7 causes grief, at least on my Mac
gem 'jakewendt-active_record_sunspotter'
#	copied in sunspot_rails-2.1.0/lib/sunspot/rails/adapters.rb
#	to stop ActiveRecord deprecation warnings


#	apparently required on new production server for some reason??
#	Otherwise ...
#jwendt@n1 : odms 504> script/rails console
#/my/ruby/gems/1.9/gems/activesupport-3.2.6/lib/active_support/dependencies.rb:251:in `require': cannot load such file -- minitest/unit (LoadError)
#	from /my/ruby/gems/1.9/gems/activesupport-3.2.6/lib/active_support/dependencies.rb:251:in `block in require'
gem 'minitest'
#
#	Thought that I fixed this, but someone is still trying to load it?
#	Seems to only be required in the console?
#	/my/ruby/gems/1.9/gems/railties-3.2.13/lib/rails/console/app.rb
#
#	Gonna have to leave it I guess
#	https://github.com/rails/rails/issues/6907
#
#	The presence of MiniTest trips a condition in the test method 'pending'
#	When it exists, it tries the 'skip' method which for some reason does
#	not exist and so fails, but only in 'rake test'.  'autotest' works???
#





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


#gem "mongrel"	#	not install in ruby19 world
#	suggested to use --pre option for 1.2.0



group :test do

	#jakewendt@fxdgroup-169-229-196-225 : odms 504> rake sunspot:solr:start RAILS_ENV=test 
	#Validating all html with http://localhost/w3c-validator/check
	#java version "1.6.0_33"
	#Java(TM) SE Runtime Environment (build 1.6.0_33-b03-424-10M3720)
	#Java HotSpot(TM) 64-Bit Server VM (build 20.8-b03-424, mixed mode)
	#Successfully started Solr ...
	#/opt/local/lib/ruby1.9/1.9.1/test/unit.rb:167:in `block in non_options': file not found: sunspot:solr:start (ArgumentError)
	#	from /opt/local/lib/ruby1.9/1.9.1/test/unit.rb:146:in `map!'
	#	from /opt/local/lib/ruby1.9/1.9.1/test/unit.rb:146:in `non_options'
	#	from /opt/local/lib/ruby1.9/1.9.1/test/unit.rb:207:in `non_options'
	#	from /opt/local/lib/ruby1.9/1.9.1/test/unit.rb:52:in `process_args'
	#	from /opt/local/lib/ruby1.9/gems/1.9.1/gems/minitest-3.3.0/lib/minitest/unit.rb:949:in `_run'
	#
	#	For some reason, starting sunspot throws an error,
	#	but doesn't actually stop it from starting.
	#	Added test-unit gem and seems to go away.  Why?  Dunno.
	#	Will this cause problems.  We shall see.
	#	
	#	i think this adds color to rake test too
	gem 'test-unit'


	#	gem "rcov"	#	not supported ruby19 world. Suggests using simplecov.
	#	This does not work as well as rcov used to, imo.
	#	simplecov-0.8.1 or one of its dependencies causes autotest to not actually run tests?
#	gem "simplecov", '0.7.1', :require => false
	gem "simplecov", :require => false


	#	for dealing with integration tests
	gem 'database_cleaner'



	#	Started getting 500 errors midway through testing.  These always
	#	occurred on testing "without login" tests.
	#		SystemStackError: stack level too deep
	#	Once this is "tripped", it always happens.
	#	I'm not really sure what the issue is, but reverting back to
	#	the mysql gem and hoping that this all goes away.
	#	While I could change the stack size with "ulimit -s",
	#	I'd rather understand what it taking up the space.
	#	Tests are supposed to clean up after themselves, but
	#	something is clearly not.
	#	mocha 0.11.4 seems to be the trigger
	#	Without the :lib => false, 'rake test' actually fails?
#	gem "mocha", '0.10.5', :require => false #	0.11.4
#	gem "mocha", :require => 'mocha/setup'

#	0.14.0 causes some failures in functional tests.  will need to investigate
#
#	despite saying that it does, 0.14.0 DOES NOT UNSTUB my stubs
#	so they require manual unstubbing.  this is just a pain
#	so reverting to 0.13.3
#
#	gem "mocha", '0.13.3', :require => false
	gem "mocha", :require => false

	#	seems that 0.14.0 doesn't unstub stubs between tests
	#		which breaks nearly everthing
	#	Also interesting that, despite being in the :test block here,
	#		the mocha methods are available in development
	#		=> rails c
	#		=> String.any_instance.... works
#	gem "mocha", :require => false
#	either false or 'mocha/setup', but something

	gem "autotest-rails", :require => 'autotest/rails'

#	to update ZenTest, need to update rubygems, bundler then ZenTest
#	sudo gem update --system			#	from rubygems-update-1.8.24 to 2.0.3
#	sudo gem update bundler
#	sudo gem update ZenTest
#	sudo bundle update

	#	try upgrading ZenTest (4.9.0 still has "illformed" gemspec (problem with old rubygems))
	gem 'ZenTest'	#, '=4.9.1'
	#	ZenTest 4.9.2 always ends tests with ...
	#Run options: --seed 6126
	#
	## Running:
	#
	#
	#
	#Finished in 0.001282s, 0.0000 runs/s, 0.0000 assertions/s.
	#
	#0 runs, 0 assertions, 0 failures, 0 errors, 0 skips
	#
	#	and uses minitest/autorun rather that test/unit
	#
	#	/opt/local/bin/ruby1.9 -I.:lib:test -rubygems -e "%w[minitest/autorun 
	#		test/integration/addressing_integration_test.rb].each { |f| require f }"
	#	
	#	/opt/local/bin/ruby1.9 -I.:lib:test -rubygems -e "%w[test/unit 
	#		test/integration/addressing_integration_test.rb].each { |f| require f }"
	#
	#	... and also does not summarize errors and failures at the end??
	#

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
gem 'geocoder', "=1.1.8"

__END__
