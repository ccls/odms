source 'https://rubygems.org'
source "http://gems.rubyforge.org"
source "http://gemcutter.org"
source "http://gems.github.com"


gem 'rails', '~> 3.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#	Don't need it.
#gem 'sqlite3'

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
#
#	Tried upgrading to the mysql2 gem as it is supposed to be faster.
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
#
#	Perhaps find some little utility to put in there to show
#	what is in the stack and then try to find out who put it there?
#
#	As I have upgraded a number of other gems, it is possible that
#	this has to do with them and not mysql2. This could be quite a 
#	challenge ... for next week.
#
#gem "mysql2"
gem "RedCloth"

#	Used for cvs parsing on data import
#	Also used to csv output.
gem "fastercsv"

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
gem "paperclip", '3.0.0'



gem 'rubycas-client'

gem 'ucb_ldap'

gem "mongrel"

gem "active_scaffold"


group :test do
	gem "rcov"
	#	Without the :lib => false, 'rake test' actually fails?
	gem "mocha", :require => false
	gem "autotest-rails", :require => 'autotest/rails'
	gem 'ZenTest'	#	, '~>4.5.0'
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
	gem 'capybara-webkit'
end

__END__
#Installing ZenTest (4.8.0) 4.7.0
#Installing multi_json (1.3.4) 1.2.0
#Installing sprockets (2.1.3) 2.1.2
#Installing actionpack (3.2.3) 
#Installing actionmailer (3.2.3) 
#Installing tzinfo (0.3.33) 0.3.32
#Installing activerecord (3.2.3) 
#Installing activeresource (3.2.3) 
#Installing json (1.7.1) with native extensions 1.6.6
#Installing railties (3.2.3) 
#Installing rails (3.2.3) 
#Installing active_scaffold (3.2.7) 
#Installing addressable (2.2.8)  ...
#Installing childprocess (0.3.2) 0.3.1
#Installing libwebsocket (0.1.3)  ..
#Installing rubyzip (0.9.8) 0.9.6.1
#Installing selenium-webdriver (2.21.2)  2.20.0
#Installing coffee-script-source (1.3.1) 1.2.0
#Installing execjs (1.3.2) 1.3.0
#Installing mocha (0.11.4) 0.10.5
#Installing sass (3.1.17) 3.1.15

