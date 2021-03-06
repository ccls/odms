require 'test_helper'

class RefusalReasonsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'RefusalReason',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_refusal_reason
	}
	def factory_attributes(options={})
		FactoryBot.attributes_for(:refusal_reason,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	add_strong_parameters_tests( :refusal_reason,
		[ :key,:description ])

end
