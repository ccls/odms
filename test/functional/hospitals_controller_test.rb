require 'test_helper'

class HospitalsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Hospital',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_hospital
	}

	def factory_attributes(options={})
		FactoryBot.attributes_for(:hospital,{
			:organization_id => FactoryBot.create(:organization).id
		}.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	add_strong_parameters_tests( :hospital,
		[ :is_active,:has_irb_waiver,:organization_id ])

end
