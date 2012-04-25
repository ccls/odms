require 'test_helper'

class InstrumentVersionsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'InstrumentVersion',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_instument_version
	}

	def factory_attributes(options={})
		Factory.attributes_for(:instument_version,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

end
