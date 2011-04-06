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
		Factory.attributes_for(:project,options)
	end

	assert_access_with_login({ 
		:logins => [:superuser,:admin,:editor,:interviewer,:reader] })
	assert_no_access_with_login({ 
		:logins => [:active_user] })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

	assert_no_access_with_login(
		:attributes_for_create => nil,
		:method_for_create => nil,
		:actions => nil,
		:suffix => " and invalid id",
		:login => :superuser,
		:redirect => :projects_path,
		:edit => { :id => 0 },
		:update => { :id => 0 },
		:show => { :id => 0 },
		:destroy => { :id => 0 }
	)

%w( superuser admin ).each do |cu|

#	save errors

	test "should NOT create when create fails with #{cu} login" do
		login_as send(cu)
		Project.any_instance.stubs(:create_or_update).returns(false)
		assert_difference('Project.count',0) {
			post :create, :project => factory_attributes
		}
		assert_response :success
		assert_template 'new'
		assert_not_nil assigns(:project)
	end

	test "should NOT update when save fails with #{cu} login" do
		login_as send(cu)
		project = create_project(:updated_at => Chronic.parse('yesterday'))
		Project.any_instance.stubs(:create_or_update).returns(false)
		deny_changes("Project.find(#{project.id}).updated_at") {
			put :update, :id => project.id,
				:project => factory_attributes
		}
		assert_response :success
		assert_template 'edit'
	end

#	test "should NOT destroy when save fails with #{cu} login" do
#		login_as send(cu)
#		project = create_project
#		Project.any_instance.stubs(:new_record?).returns(true)
#		assert_difference('Project.count',0){
#			delete :destroy, :id => project.id
#		}
##		assert_not_nil flash[:error]
#		assert_redirected_to projects_path
#	end

#	invalid project

	test "should NOT create with invalid project with #{cu} login" do
		login_as send(cu)
		Project.any_instance.stubs(:valid?).returns(false)
		assert_difference('Project.count',0) do
			post :create, :project => factory_attributes
		end
		assert_not_nil assigns(:project)
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	test "should NOT update with invalid project with #{cu} login" do
		project = create_project(:updated_at => Chronic.parse('yesterday'))
		Project.any_instance.stubs(:valid?).returns(false)
		login_as send(cu)
		deny_changes("Project.find(#{project.id}).updated_at") {
			put :update, :id => project.id, 
				:project => factory_attributes
		}
		assert_not_nil assigns(:project)
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

end

end
