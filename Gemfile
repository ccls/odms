source 'https://rubygems.org'
source "http://gems.rubyforge.org"
source "http://gemcutter.org"
source "http://gems.github.com"


gem 'rails', '3.2.2'

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

gem "paperclip"

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
