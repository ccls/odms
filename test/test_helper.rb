require 'simplecov_test_helper'	#	should be first for some reason

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'test_helper_helper'

require 'factory_test_helper'
#require 'partial_abstract_controller_test_helper'
#require 'abstract_base_controller_test_helper'

#	These are not automatically included as they
#		contain duplicate methods names.
#	They must be explicitly included in the test classes
#		that use them.
#	I'd like to uniqify these so that they aren't special
#require 'birth_datum_update_test_helper'

class ActiveSupport::TestCase

	fixtures :all

	def login_as( user=nil )
		uid = ( user.is_a?(User) ) ? user.uid : user
		if !uid.blank?
			@request.session[:calnetuid] = uid
			stub_ucb_ldap_person()
			User.find_create_and_update_by_uid(uid)

			CASClient::Frameworks::Rails::Filter.stubs(
				:filter).returns(true)
			# No longer using the GatewayFilter stuff.
			# CASClient::Frameworks::Rails::GatewayFilter.stubs(
			# :filter).returns(true)
		end
	end
#	alias :login :login_as
#	alias :log_in :login_as


	def stub_ucb_ldap_person(options={})
		UCB::LDAP::Person.stubs(:find_by_uid).returns(
			UCB::LDAP::Person.new({
				:sn => ["Wendt"],
				:displayname => ["Mr. Jake Wendt, BA"],
				:telephonenumber => ["+1 510 642-9749"],
				:mail => []
			})
		)
		# Load schema locally for offline testing.
		# This will generate this warning...
		# Warning: schema loading from file
		# from ucb_ldap-1.3.2/lib/ucb_ldap_schema.rb
		# Comment this out to get the schema from Cal.
		# This will generate this warning...
		# warning: peer certificate won't be verified in this SSL session
		UCB::LDAP::Schema.stubs(
			:load_attributes_from_url).raises(StandardError)
	end

	def assert_redirected_to_login
		assert_response :redirect
		assert_match "https://auth-test.berkeley.edu/cas/login",
			@response.redirect_url
	end

	def assert_redirected_to_logout
		assert_response :redirect
		assert_match "https://auth-test.berkeley.edu/cas/logout",
			@response.redirect_url
	end

	def assert_logged_in
		assert_not_nil session[:calnetuid]
	end

	def assert_not_logged_in
		assert_nil session[:calnetuid]
	end

	def active_user(options={})
		u = FactoryBot.create(:user, options)
		#	leave this special save here just in case I change things.
		#	although this would need changed for UCB CAS.
		#	u.save_without_session_maintenance
		#	u
	end
	alias_method :user, :active_user

	def superuser(options={})
		u = active_user(options)
		u.roles << Role.find_or_create_by(name: 'superuser')
		u
	end
	alias_method :super_user, :superuser

	def admin_user(options={})
		u = active_user(options)
		u.roles << Role.find_or_create_by(name: 'administrator')
		u
	end
	alias_method :admin, :admin_user
	alias_method :administrator, :admin_user

#	def interviewer(options={})
#		u = active_user(options)
#		u.roles << Role.find_or_create_by(name: 'interviewer')
#		u
#	end

	def reader(options={})
		u = active_user(options)
		u.roles << Role.find_or_create_by(name: 'reader')
		u
	end
#	alias_method :employee, :reader

	def editor(options={})
		u = active_user(options)
		u.roles << Role.find_or_create_by(name: 'editor')
		u
	end

	def exporter(options={})
		u = active_user(options)
		u.roles << Role.find_or_create_by(name: 'exporter')
		u
	end

	class << self

		def site_superusers
			@site_superusers ||= %w( superuser )
		end

		def non_site_superusers
			@non_site_superusers ||= ( all_test_roles - site_superusers )
		end

		def site_administrators
			@site_administrators ||= %w( superuser administrator )
		end

		def non_site_administrators
			@non_site_administrators ||= ( all_test_roles - site_administrators )
		end

		def site_exporters
			@site_exporters ||= %w( superuser administrator exporter )
		end

		def non_site_exporters
			@non_site_exporters ||= ( all_test_roles - site_exporters )
		end

		def site_editors
			@site_editors ||= %w( superuser administrator exporter editor )
		end

		def non_site_editors
			@non_site_editors ||= ( all_test_roles - site_editors )
		end

		def site_readers
#			@site_readers ||= %w( superuser administrator editor interviewer reader )
			@site_readers ||= %w( superuser administrator exporter editor reader )
		end

		def non_site_readers
			@non_site_readers ||= ( all_test_roles - site_readers )
		end

		def all_test_roles
#			@all_test_roles = %w( superuser administrator editor interviewer reader active_user )
			@all_test_roles = %w( superuser administrator exporter editor reader active_user )
		end

	end	#	class << self

end




#	as per 0.14.0 instructions, at the bottom of test_helper
#require 'mocha/setup'
#	still causes many failures due to unstubbing

