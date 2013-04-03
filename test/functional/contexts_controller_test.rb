require 'test_helper'

class ContextsControllerTest < ActionController::TestCase
#
#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Context',
#		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_context
#	}
#
#	def factory_attributes(options={})
#		FactoryGirl.attributes_for(:context,options)
#	end
#
#	assert_access_with_login({    :logins => site_administrators })
#	assert_no_access_with_login({ :logins => non_site_administrators })
#	assert_no_access_without_login
#
#	site_administrators.each do |cu|
#
#		#	special tests to test the html validity with content
#
#		test "should edit context with contextables and #{cu} login" do
#			login_as send(cu)
#			get :edit, :id => ::Context[:raf1].id
#			assert_response :success
#			assert_template 'edit'
#		end
#
#		test "should show context with contextables and #{cu} login" do
#			login_as send(cu)
#			get :show, :id => ::Context[:raf1].id
#			assert_response :success
#			assert_template 'show'
#		end
#
#	end
#
end
