require 'test_helper'

class OdmsExceptionsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'OdmsException',
		:actions => [:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_odms_exception
	}

	#	no fields in factory, so no changes on update, so force the
	#	issue by make the updated_at date different
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:odms_exception,{
			:updated_at => Date.yesterday }.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

end
