require 'test_helper'

class SampleKitsControllerTest < ActionController::TestCase

	#	no route as is has_one
	assert_no_route(:get, :index, :sample_id => 0)

	#	no sample_id
	assert_no_route(:get, :new)
	assert_no_route(:post, :create)

	# no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	setup :build_sample_kit
	def build_sample_kit
		@sample_kit = create_sample_kit
		@sample = @sample_kit.sample
	end

	ASSERT_ACCESS_OPTIONS = {
		:model => 'SampleKit',
		:actions => [:show,:edit,:update,:destroy],	#	the shallow routes
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample_kit
	}

	def factory_attributes(options={})
		#	No attributes from Factory yet
		Factory.attributes_for(:sample_kit,{
			:updated_at => Time.now}.merge(options))
	end

	assert_access_with_login({ 
		:logins => [:superuser,:admin] })
	assert_no_access_with_login({ 
		:logins => [:editor,:interviewer,:reader,:active_user] })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

	assert_no_access_with_login(
		:attributes_for_create => nil,
		:method_for_create => nil,
		:actions => nil,
		:suffix => " and invalid id",
		:login => :superuser,
		:redirect => :subjects_path,
		:edit => { :id => 0 },
		:update => { :id => 0 },
		:show => { :id => 0 },
		:destroy => { :id => 0 }
	) 


#	not logged in

	test "should NOT get new without login" do
		get :new, :sample_id => @sample.id
		assert_redirected_to_login
	end

	test "should NOT create without login" do
		assert_difference('SampleKit.count',0){
			post :create, :sample_id => @sample.id, 
				:sample_kit => factory_attributes
		}
		assert_redirected_to_login
	end

%w( superuser admin ).each do |cu|

	test "should get new with #{cu} login" do
		login_as send(cu)
		get :new, :sample_id => @sample.id
		assert_response :success
		assert_template 'new'
		assert assigns(:sample_kit)
#		assert_layout 'home_exposure'
	end

	test "should create with #{cu} login" do
		login_as send(cu)
		assert_difference('SampleKit.count',1) {
			post :create, :sample_id => @sample.id,
				:sample_kit => factory_attributes
		}
		assert_redirected_to subject_path(assigns(:sample_kit).sample.subject)
	end

	test "should show with #{cu} login and packages" do
		sk = create_sample_kit(
			:kit_package_attributes  => Factory.attributes_for(:package),
			:sample_package_attributes => Factory.attributes_for(:package)
		)
		login_as send(cu)
		get :show, :id => sk.id
		assert_response :success
		assert_template 'show'
		assert assigns(:sample_kit)
	end

#	save errors

	test "should create with empty packages with #{cu} login" do
		login_as send(cu)
		assert_difference('SampleKit.count',1) {
			post :create, :sample_id => @sample.id,
				:sample_kit => {
					:kit_package_attributes  => {},
					:sample_package_attributes => {} 
				}
		}
		assert_redirected_to subject_path(@sample.subject)
	end

	test "should NOT create with #{cu} login " <<
		"with save failure" do
		login_as send(cu)
		SampleKit.any_instance.stubs(:create_or_update).returns(false)
		assert_difference('SampleKit.count',0) {
			post :create, :sample_id => @sample.id,
				:sample_kit => factory_attributes
		}
		assert_response :success
		assert_template 'new'
	end

	test "should NOT create with #{cu} login " <<
		"with invalid kit" do
		login_as send(cu)
		SampleKit.any_instance.stubs(:valid?).returns(false)
		assert_difference('SampleKit.count',0) {
			post :create, :sample_id => @sample.id,
				:sample_kit => factory_attributes
		}
		assert_response :success
		assert_template 'new'
	end

	test "should update with empty packages with #{cu} login" do
		login_as send(cu)
		sample_kit = create_sample_kit(:updated_at => Chronic.parse('yesterday'))
		assert_changes("SampleKit.find(#{sample_kit.id}).updated_at") {
			put :update, :id => sample_kit.id,
				:sample_kit => {
					:kit_package_attributes  => {},
					:sample_package_attributes => {} 
				}
		}
		assert_redirected_to subject_path(sample_kit.sample.subject)
	end

	test "should NOT update with #{cu} login " <<
		"with save failure" do
		login_as send(cu)
		sample_kit = create_sample_kit(:updated_at => Chronic.parse('yesterday'))
		SampleKit.any_instance.stubs(:create_or_update).returns(false)
		deny_changes("SampleKit.find(#{sample_kit.id}).updated_at") {
			put :update, :id => sample_kit.id,
				:sample_kit => factory_attributes
		}
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT update with #{cu} login " <<
		"with invalid kit" do
		login_as send(cu)
		sample_kit = create_sample_kit(:updated_at => Chronic.parse('yesterday'))
		SampleKit.any_instance.stubs(:valid?).returns(false)
		deny_changes("SampleKit.find(#{sample_kit.id}).updated_at") {
			put :update, :id => sample_kit.id,
				:sample_kit => factory_attributes
		}
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT destroy with #{cu} login " <<
		"with destruction failure" do
		login_as send(cu)
		SampleKit.any_instance.stubs(:new_record?).returns(true)
		assert_difference('SampleKit.count',0){
			delete :destroy, :id => @sample_kit.id
		}
		assert_redirected_to subject_path(assigns(:sample_kit).sample.subject)
	end

#	INVALID sample_id

	test "should NOT get new with invalid sample_id with #{cu} login" do
		login_as send(cu)
		get :new, :sample_id => 0
		assert_redirected_to subjects_path
		assert_not_nil flash[:error]
	end

	test "should NOT post create with invalid sample_id with #{cu} login" do
		login_as send(cu)
		assert_difference('SampleKit.count',0) {
			post :create, :sample_id => 0,
				:sample_kit => factory_attributes
		}
		assert_redirected_to subjects_path
		assert_not_nil flash[:error]
	end


#	invalid sample kit
#	(no validations yet so no tests yet)

end

%w( editor interviewer reader active_user ).each do |cu|

	test "should NOT get new with #{cu} login" do
		login_as send(cu)
		get :new, :sample_id => @sample.id
		assert_redirected_to root_path
	end

	test "should NOT post create with #{cu} login" do
		login_as send(cu)
		assert_difference('SampleKit.count',0) {
			post :create, :sample_id => @sample.id,
				:sample_kit => factory_attributes
		}
		assert_redirected_to root_path
	end

end

end
