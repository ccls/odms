require 'test_helper'

class AbstractsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Abstract',
		:actions => [:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_abstract
	}
	def factory_attributes(options={})
		Factory.attributes_for(:complete_abstract,{
		}.merge(options))
	end

	assert_access_with_login({ 
		:logins => site_editors })
	assert_no_access_with_login({ 
		:logins => ( all_test_roles - site_editors ) })
	assert_no_access_without_login

	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

end
