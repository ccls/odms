require 'test_helper'

class IcfMasterTrackersControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IcfMasterTracker',
		:actions => [:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_icf_master_tracker
	}
	def factory_attributes(options={})
		Factory.attributes_for(:icf_master_tracker,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

end
