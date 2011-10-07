require 'test_helper'

class GuidesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Guide',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_guide
	}

	def factory_attributes(options={})
		Factory.attributes_for(:guide,options)
	end

	assert_access_with_login({ 
		:logins => site_editors })
	assert_no_access_with_login({ 
		:logins => non_site_editors })
	assert_no_access_without_login

#	TODO duplicate?
#	assert_no_access_with_login(
#		:attributes_for_create => nil,
#		:method_for_create => nil,
#		:actions => nil,
#		:suffix => " and invalid id",
#		:login => :superuser,
#		:redirect => :guides_path,
#		:edit => { :id => 0 },
#		:update => { :id => 0 },
#		:show => { :id => 0 },
#		:destroy => { :id => 0 }
#	) 

#	TODO duplicate?
#	site_administrators.each do |cu|
#
#		test "should NOT create new guide with #{cu} login when create fails" do
#			Guide.any_instance.stubs(:create_or_update).returns(false)
#			login_as send(cu)
#			assert_difference('Guide.count',0) do
#				post :create, :guide => factory_attributes
#			end
#			assert assigns(:guide)
#			assert_response :success
#			assert_template 'new'
#			assert_not_nil flash[:error]
#		end
#
#		test "should NOT create new guide with #{cu} login and invalid guide" do
#			Guide.any_instance.stubs(:valid?).returns(false)
#			login_as send(cu)
#			assert_difference('Guide.count',0) do
#				post :create, :guide => factory_attributes
#			end
#			assert assigns(:guide)
#			assert_response :success
#			assert_template 'new'
#			assert_not_nil flash[:error]
#		end
#
#		test "should NOT update guide with #{cu} login when update fails" do
#			guide = create_guide(:updated_at => Chronic.parse('yesterday'))
#			Guide.any_instance.stubs(:create_or_update).returns(false)
#			login_as send(cu)
#			deny_changes("Guide.find(#{guide.id}).updated_at") {
#				put :update, :id => guide.id,
#					:guide => factory_attributes
#			}
#			assert assigns(:guide)
#			assert_response :success
#			assert_template 'edit'
#			assert_not_nil flash[:error]
#		end
#
#		test "should NOT update guide with #{cu} login and invalid guide" do
#			guide = create_guide(:updated_at => Chronic.parse('yesterday'))
#			Guide.any_instance.stubs(:valid?).returns(false)
#			login_as send(cu)
#			deny_changes("Guide.find(#{guide.id}).updated_at") {
#				put :update, :id => guide.id,
#					:guide => factory_attributes
#			}
#			assert assigns(:guide)
#			assert_response :success
#			assert_template 'edit'
#			assert_not_nil flash[:error]
#		end
#
#	end

end
