require 'test_helper'

class AbstractsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Abstract',
#		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
#		:actions => [:edit,:update,:show,:destroy,:index],
		:actions => [:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_abstract
	}
	def factory_attributes(options={})
		#	:abstract worked yesterday, but not today???
		#	updates were not updating
		Factory.attributes_for(:complete_abstract,{
#			:study_subject_id => Factory(:case_study_subject).id
		}.merge(options))
	end

	assert_access_with_login({ 
		:logins => site_administrators })
	assert_no_access_with_login({ 
		:logins => ( all_test_roles - site_administrators ) })
	assert_no_access_without_login

	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

end
