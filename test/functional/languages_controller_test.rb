require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Language',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_language
	}
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:language,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	add_strong_parameters_tests( :language,
		[ :key,:code,:description ])

end
