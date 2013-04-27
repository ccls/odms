require 'test_helper'

class BirthDataControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'BirthDatum',
#		:actions => [:edit,:update,:show,:index,:destroy],
		:actions => [:show,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_birth_datum
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:birth_datum,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

end
