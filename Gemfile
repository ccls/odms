source 'https://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#	Don't need it.
#gem 'sqlite3'

gem 'json'

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

#gem "ssl_requirement"
#	rails 3 version, but apparently there is a better way
#gem 'bartt-ssl_requirement', :require => 'ssl_requirement'

#	don't need it and its not rails 3 compatible
#gem "jrails"

gem "ryanb-acts-as-list", :require => 'acts_as_list'

gem "will_paginate"

gem "hpricot"

#	config.gem 'paperclip'	#, '=2.4.2'
#	2.4.3, 2.4.5 causes a lot of ...
#	NameError: `@[]' is not allowed as an instance variable name
#    paperclip (2.4.5) lib/paperclip/options.rb:60:in `instance_variable_get'
#    paperclip (2.4.5) lib/paperclip/options.rb:60:in `method_missing'
gem "paperclip"	#, '=2.4.2'	#	only used by buffler and clic
#	actually, now will be used for live_birth_data, so all apps need it

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

	#	rails 3 version
	gem "factory_girl_rails"	#, :require    => "factory_girl"
	#	:source => "http://gems.github.com"

	#	TODO gonna need to fix this
	#gem 'ccls-html_test'

	gem 'webrat'
	gem 'capybara'
	gem 'capybara-webkit'
end


#	The console start
#	The server starts
#	Can't run autotest yet though
#	I remember having to fix something like this before....
#	I is in my ~/.autotest file

#	/Library/Ruby/Gems/1.8/gems/ZenTest-4.5.0/lib/unit_diff.rb:72:in `gets': No such file or directory - -u (Errno::ENOENT)






#	# A sample Gemfile
#	source "http://rubygems.org"
#	source "http://gems.rubyforge.org"
#	source "http://gemcutter.org"
#	
#	#	I don't believe that this source is active any longer.
#	source "http://gems.github.com"
#	
#	
#	#	rubygems > 1.6.2 is EVIL!  If you update, you deal with it.
#	#		generates all kinds of new errors and deprecation warnings
#	#		somehow loads older versions of gems, then bitches when you try to load the newest.
#	#		(may be fixable with "gem pristine --all --no-extensions", but haven't tried)
#	#	rake 0.9.0 caused some errors.  can't remember
#	#	arel > 2.0.2 caused some errors.
#	#	some gem versions require rails 3, so have to use older versions
#	#		authlogic, will_paginate
#	
#	
#	#	buffler and clic now have their own Gemfiles
#	#	so the special mods for jruby are no longer needed.
#	
#	
#	#
#	#	NO SPACES BETWEEN OPERATOR AND VERSION NUMBER!
#	#
#	gem "rake", '=0.8.7'
#	gem "rails", "~>2"
#	
#	
#	#	20120213 - Removing this feature
#	#gem "active_shipping"
#	
#	
#	gem "arel", "=2.0.2"
#	
#	
#	
#	gem "haml"
#	gem "i18n"
#	gem "jeweler"
#	
#	#	causes rails 2.3.2 and associated to be installed???
#	#gem "rack"	
#	# (1.3.0, 1.2.2, 1.1.2, 1.1.0, 1.0.1)
#	
#	
#	#gem "ccls-calnet_authenticated"
#	#gem "ccls-ccls_engine"
#	#gem "ccls-common_lib"
#	#gem "ccls-simply_authorized"
#	#gem "ccls-use_db"
#	
#	#if RUBY_PLATFORM =~ /java/
#	#	gem "warbler"
#	#	gem "jruby-jars"
#	#	gem "jruby-openssl"
#	#	gem "jruby-rack"
#	#	gem "jdbc-mysql"
#	#	gem "jdbc-sqlite3"
#	#	gem "activerecord-jdbcsqlite3-adapter"
#	#	gem "activerecord-jdbcmysql-adapter"
#	#
#	##Java::JavaLang::ArrayIndexOutOfBoundsException: An error occured while installing rubyzip (0.9.5), and Bundler cannot continue.
#	#	gem 'rubyzip', '=0.9.4'	#	0.9.5 fails
#	#else
#		#	problems in jruby
#	#	gem "sqlite3", '!=1.3.4'
#	#end
#	
#	gem "packet"	#	don't remember why (think from backgroundrb)
#	
#	
#	
#	
#	
#	#	Rails 2 requires us to not use the latest version of delayed_job.
#	#	delayed_job depends upon version 1.0.10 of the daemons gem.
#	#	delayed_job is incompatible with the newest (1.1.0) daemons gem.
#	#Installing daemons (1.0.10) 
#	#Installing delayed_job (2.0.7) 
#	#gem 'delayed_job', '~>2.0.4'
#	
#	
#	#	These gems are not needed in production
#	#	They will be skipped because of config file
#	#	/my/ruby/.bundle/config 
#	#--- 
#	#BUNDLE_WITHOUT: development:test
#	#
#	group :development do
#	#	unless RUBY_PLATFORM =~ /java/
#	#		#	doesn't install with native extensions
#	#		gem "rmagick"	#	only used with paperclip on buffler and clic
#	#	end
#		#	rarely used
#		gem "rdoc"
#	
#		#	only used by clic
#	#	gem "authlogic", "~>2"	
#	
#		#	only used by buffler and clic
#		gem "aws-s3"
#	
#		#	Never used anymore
#		#gem "aws-sdb"
#	
#		#	sunspot is only used by clic, and that has even stopped
#		#	It seems that 1.3.0 will require some modifications.
#	#	I am going to possibly try to use this with ccls
#	#	gem "sunspot_rails", '=1.2.1'
#	#	gem "sunspot", '=1.2.1'
#	#	gem "rsolr", '=0.12.1'
#	end
#	
#	
#	group :test do
#		#	used only by simply_authorized in testing (so I'd actually like to remove)
#	#	now dead.
#	#	gem "ccls-simply_sessions"	
#	
#		#	really only needed in test environment
#		#	but some of my gems still require it
#		gem "thoughtbot-factory_girl"	
#	
#		#	My many testing gems
#		gem "ccls-html_test"
#		gem "autotest-rails"
#	
#		gem "rcov" unless RUBY_PLATFORM =~ /java/
#	
#	
#	#	I don't know why, but each of these will trigger
#	#	the installation of rails 2.3.2 and I don't quite
#	#	understand why.
#	#	gem "webrat"
#	#	gem "capybara"
#	#	gem "capybara-webkit"
#	end
