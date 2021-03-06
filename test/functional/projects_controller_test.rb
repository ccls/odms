require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

	#	no id
	assert_no_route(:get,:show)
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Project',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_project
	}

	def factory_attributes(options={})
		FactoryBot.attributes_for(:project,options)
	end

	assert_access_with_login({ 
		:actions => [:show,:index],
		:logins => site_readers })
	assert_no_access_with_login({ 
		:actions => [:show,:index],
		:logins => non_site_readers })

	assert_access_with_login({ 
		:actions => [:new,:create,:edit,:update],
		:logins => site_editors })
	assert_no_access_with_login({ 
		:actions => [:new,:create,:edit,:update],
		:logins => non_site_editors })

	assert_access_with_login({ 
		:actions => [:destroy],
		:logins => site_administrators })
	assert_no_access_with_login({ 
		:actions => [:destroy],
		:logins => non_site_administrators })

	assert_no_access_without_login

	add_strong_parameters_tests( :project,
		[ :key,:label,:description ])

end
