require 'test_helper'

class UsersControllerTest < ActionController::TestCase

	test "should get blank user menu in js without login" do
		@request.accept = "text/javascript"
		get :menu
		assert_response :success
		assert @response.body.blank?
	end

	test "should get blank user menu in js with active_user login" do
		@request.accept = "text/javascript"
		login_as active_user
		get :menu
		assert_response :success
		assert @response.body.blank?
	end

	test "should get user menu in js with admin login" do
		@request.accept = "text/javascript"
		login_as admin_user
		get :menu
		assert_response :success
		assert !@response.body.blank?
		assert_match /jQuery/, @response.body
#jQuery(function(){
#	jQuery('div#mainmenu').append('<a href="/admin">Admin</a>');
#});
	end

end
