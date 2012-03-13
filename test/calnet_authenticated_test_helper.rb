module CalnetAuthenticatedTestHelper

	def self.included(base)
		base.extend(ClassMethods)
	end

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
	alias :login :login_as
	alias :log_in :login_as


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
			@response.redirected_to
	end

	def assert_redirected_to_logout
		assert_response :redirect
		assert_match "https://auth-test.berkeley.edu/cas/logout",
			@response.redirected_to
	end

	def assert_logged_in
		assert_not_nil session[:calnetuid]
	end

	def assert_not_logged_in
		assert_nil session[:calnetuid]
	end

	module ClassMethods

		def site_administrators
			@site_administrators ||= %w( superuser administrator )
		end

		def non_site_administrators
			@non_site_administrators ||= ( all_test_roles - site_administrators )
		end

		def site_editors
			@site_editors ||= %w( superuser administrator editor )
		end

		def non_site_editors
			@non_site_editors ||= ( all_test_roles - site_editors )
		end

		def site_readers
			@site_readers ||= %w( superuser administrator editor interviewer reader )
		end

		def non_site_readers
			@non_site_readers ||= ( all_test_roles - site_readers )
		end

		def all_test_roles
			@all_test_roles = %w( superuser administrator editor interviewer reader active_user )
		end
	end

end	#	module CalnetAuthenticated::TestHelper

require 'active_support'
require 'active_support/test_case'
ActiveSupport::TestCase.send(:include,CalnetAuthenticatedTestHelper)
