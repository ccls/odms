require 'test_helper'

class SampleTypesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'SampleType',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample_type
	}

	def factory_attributes(options={})
		FactoryBot.attributes_for(:sample_type,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	add_strong_parameters_tests( :sample_type,
		[ :parent_id,:key,:description, :for_new_sample,:t2k_sample_type_id,
			:gegl_sample_type_id ])

end
