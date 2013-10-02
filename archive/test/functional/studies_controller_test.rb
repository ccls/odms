require 'test_helper'

class StudiesControllerTest < ActionController::TestCase

	site_readers.each do |cu|

		test "should get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
	end

	test "should NOT get dashboard without login" do
		get :dashboard
		assert_redirected_to_login
	end

end
