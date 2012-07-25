source 'https://rubygems.org'
source "http://gems.rubyforge.org"
source "http://gemcutter.org"
source "http://gems.github.com"




gem 'sunspot_rails'
gem 'sunspot_solr' # optional pre-packaged Solr distribution for use in development
gem 'sqlite3'


#	apparently required on new production server for some reason??
#	Otherwise ...
#jwendt@n1 : odms 504> script/rails console
#/my/ruby/gems/1.9/gems/activesupport-3.2.6/lib/active_support/dependencies.rb:251:in `require': cannot load such file -- minitest/unit (LoadError)
#	from /my/ruby/gems/1.9/gems/activesupport-3.2.6/lib/active_support/dependencies.rb:251:in `block in require'
gem 'minitest'

#	PDF generation
gem 'prawn'
gem 'prawnto'

#	ruby 1.9.3 requirement to parse american date
#	format Month/Day/Year Date.parse('12/31/2000')
gem 'american_date'

gem 'rails', '~> 3.2.2' 

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'json'

gem 'sass'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

gem 'rack-ssl', :require => 'rack/ssl'

gem "mysql"
gem "mysql2"
gem "RedCloth"

#	Used for cvs parsing on data import
#	Also used to csv output.
#gem "fastercsv"
#	fastercsv has been included in ruby 1.9.3
#	however it goes by CSV rather than FasterCSV.

#
#	TODO	am I still using this anywhere?
#
#	Trying to remove Chronic usage
#	still in calnet_authenticated
#	0.6.7 doesn't install in jruby?
gem "chronic"	#,	'<=0.6.6'

gem "ryanb-acts-as-list", :require => 'acts_as_list'

gem "will_paginate"

gem "hpricot"


#
#	20120403 - paperclip 3.0.1 yields ...
#	https://github.com/thoughtbot/paperclip/issues/807
#	NoMethodError: undefined method `tempfile' for #<Tempfile:0x106350550>
#
#	20120510 - paperclip 3.0.2 ...
# sudo gem install paperclip -v '3.0.2'
#Fetching: paperclip-3.0.2.gem (100%)
#ERROR:  Error installing paperclip:
#	paperclip requires Ruby version >= 1.9.2.
#
#	20120510 - paperclip 3.0.3 ...
#Installing paperclip (3.0.3) 
#Gem::InstallError: paperclip requires Ruby version >= 1.9.2.
#An error occured while installing paperclip (3.0.3), and Bundler cannot continue.
#Make sure that `gem install paperclip -v '3.0.3'` succeeds before bundling.
#
#	20120530 - paperclip 3.0.0 has been yanked
#		and all the new stuff requires ruby 1.9.2
#		must downgrade to 2.7.0
#
#gem "paperclip", '~> 2.7'
#
#	20120614 - we are upgrading to ruby 1.9.3
gem "paperclip"

gem 'rubycas-client'

#gem 'ucb_ldap'
gem 'net-ldap'





#gem "mongrel"	#	not install in ruby19 world
#	suggested to use --pre option for 1.2.0





gem "active_scaffold"


group :test do




#	gem "rcov"	#	not supported ruby19 world. Suggests using simplecov.
#	This does not work as well as rcov used to, imo.
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
	gem "mocha", '0.10.5', :require => false #	0.11.4

	gem "autotest-rails", :require => 'autotest/rails'

	gem 'ZenTest'
	#		#Fetching: ZenTest-4.6.2.gem (100%)
	#		#ERROR:  Error installing ZenTest:
	#		#	ZenTest requires RubyGems version ~> 1.8. (which is evil I tell you)

	#gem "thoughtbot-factory_girl", :require    => "factory_girl"
	#Gem::InstallError: factory_girl requires Ruby version >= 1.9.2.
	#An error occured while installing factory_girl (3.0.0), and Bundler cannot continue.
	#Make sure that `gem install factory_girl -v '3.0.0'` succeeds before bundling.
	gem "factory_girl", "~> 2.6.0"
	#	rails 3 version
	gem "factory_girl_rails"	#, :require    => "factory_girl"

	gem 'ccls-html_test'
	gem 'webrat'
	gem 'capybara'
	gem 'capybara-webkit'	#, '0.11.0'
end

__END__

# new in file	(version that worked) (version that MAY not)

gem 'multi_json', '1.2.0'	#	1.3.5
gem 'coffee-script-source', '1.2.0'	#	1.3.1
gem 'sprockets', '2.1.2'	#	2.1.3
gem 'execjs', '1.3.0'	#	1.3.2
gem 'rubyzip', '0.9.6.1'	#	0.9.8
gem 'childprocess', '0.3.1'	#	0.3.2
gem 'tzinfo', '0.3.32'	#	0.3.33

