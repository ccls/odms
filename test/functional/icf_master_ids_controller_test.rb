require 'test_helper'

class IcfMasterIdsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IcfMasterId',
		:actions => [:show,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_icf_master_id
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:icf_master_id,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

end
