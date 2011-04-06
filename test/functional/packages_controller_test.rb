require 'test_helper'

class PackagesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Package',
#		:actions => [:new,:show,:destroy,:index],	#	FedEx API not working anymore????
		:actions => [:new,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_package
	}

	def factory_attributes(options={})
		Factory.attributes_for(:package,options)
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
		:redirect => :packages_path,
		:update => { :id => 0 },
		:show => { :id => 0 }, 
		:destroy => { :id => 0 }
	)

#	create and update both call update_status which will 
#	contact FedEx and can slow things down.  To speed things
#	up, I stub.

%w( superuser admin editor interviewer reader ).each do |cu|

	test "delivered packages should NOT have update status link " <<
		"with #{cu} login" do
		create_package(:status => "Delivered")
		login_as send(cu)
		get :index
		assert_select "div.update" do
			assert_select "a", :count => 0
		end
	end

	test "undelivered packages should have update status link " <<
		"with #{cu} login" do
		create_package
		login_as send(cu)
		get :index
		assert_select "div.update" do
			assert_select "a", :count => 1
		end
	end

	test "should create package with #{cu} login" do
		stub_package_for_in_transit	#	remove external dependency
		login_as send(cu)
		assert_difference('Package.count',1) do
			post :create, :package => factory_attributes
		end
		assert_not_nil assigns(:package)
		assert_redirected_to packages_path
	end

	test "should NOT create package with #{cu} login " <<
		"and invalid package" do
		login_as send(cu)
		Package.any_instance.stubs(:valid?).returns(false)
		assert_difference('Package.count',0) do
			post :create, :package => {}
		end
		assert_not_nil assigns(:package)
		assert_response :success
		assert_template 'new'
	end

	test "should NOT create package with #{cu} login " <<
		"and package create fails" do
		login_as send(cu)
		Package.any_instance.stubs(:create_or_update).returns(false)
		assert_difference('Package.count',0) do
			post :create, :package => {}
		end
		assert_not_nil assigns(:package)
		assert_response :success
		assert_template 'new'
	end

	test "should update with #{cu} login" do
		stub_package_for_successful_delivery	#	remove external dependency
		login_as send(cu)
		package = create_package(:tracking_number => '077973360403984')
		assert_nil package.status
		put :update, :id => package.id
		assert_not_nil package.reload.status
		assert_redirected_to packages_path
	end

	test "should update and redirect to referer if set " <<
		"with #{cu} login" do
		stub_package_for_successful_delivery	#	remove external dependency
		login_as send(cu)
		package = create_package
		@request.env["HTTP_REFERER"] = package_path(package)
#	all currently result in the same redirect
#		@request.session[:refer_to] = package_path(package)
#		session[:refer_to] = package_path(package)
		put :update, :id => package.id
		assert_redirected_to package_path(package)
	end

	test "should simulate ship with #{cu} login" do
		login_as send(cu)
		package = create_package
		assert_not_equal 'Transit', package.reload.status
		put :ship, :id => package.id
		assert_equal 'Transit', package.reload.status
		assert_response :redirect
	end

	test "should simulate delivery with #{cu} login" do
		login_as send(cu)
		package = create_package
		assert_not_equal 'Delivered', package.reload.status
		put :deliver, :id => package.id
		assert_equal 'Delivered', package.reload.status
		assert_response :redirect
	end

	test "should show tracks for package with #{cu} login" do
		stub_package_for_successful_delivery
		login_as send(cu)
		package = create_package
		package.update_status
		assert package.tracks.length > 0
		get :show, :id => package.id
		assert_response :success
		assert_template 'show'
		assert_select 'div#tracks' do
			assert_select 'div.track'
		end
	end

end

%w( active_user ).each do |cu|

	test "should NOT update with #{cu} login" do
		login_as send(cu)
		package = create_package(:tracking_number => '077973360403984')
		assert_nil package.status
		put :update, :id => package.id
		assert_nil package.reload.status
		assert_redirected_to root_path
	end

end

	test "should NOT update without login" do
		package = create_package(:tracking_number => '077973360403984')
		assert_nil package.status
		put :update, :id => package.id
		assert_nil package.reload.status
		assert_redirected_to_login
	end

end
