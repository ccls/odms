require 'test_helper'

class PhoneTypesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'PhoneType',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_phone_type
	}

	def factory_attributes(options={})
		Factory.attributes_for(:phone_type,options)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

end
