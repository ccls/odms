require 'test_helper'

class UsersControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'User',
		:actions => [:destroy,:index,:show],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :factory_create
	}

	def factory_attributes
		FactoryGirl.attributes_for(:user)
	end
	def factory_create
		FactoryGirl.create(:user)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	#	use full role names as used in one test method
	site_administrators.each do |cu|

#	TODO these tests only test the inclusion
#		they don't test the exclusion
	
		test "should filter users index by role with #{cu} login" do
			roleless_user = FactoryGirl.create(:user)
			some_other_user = send(cu)
			login_as send(cu)
			assert_equal User.all.length, 3
			get :index, :role_name => cu
			assert assigns(:users).length == 2
			assigns(:users).each do |u|
				assert u.role_names.include?(cu)
			end
			assert !assigns(:users).include?(roleless_user)
			assert_nil flash[:error]
			assert_response :success
		end
	
		test "should ignore empty role_name with #{cu} login" do
			some_other_user = admin
			login_as send(cu)
			get :index, :role_name => ''
			assert assigns(:users).length >= 2
			assert_nil flash[:error]
			assert_response :success
		end
	
		test "should ignore invalid role with #{cu} login" do
			login_as send(cu)
			get :index, :role_name => 'suffocator'
			assert_response :success
		end
	
	end
	
	all_test_roles.each do |cu|
	
		test "should NOT get user info with invalid id with #{cu} login" do
			login_as send(cu)
			get :show, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to users_path
		end
	
		test "should get #{cu} info with self login" do
			u = send(cu)
			login_as u
			get :show, :id => u.id
			assert_response :success
			assert_not_nil assigns(:user)
			assert_equal u, assigns(:user)
		end
	
	end

end


__END__
