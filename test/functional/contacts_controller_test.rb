require 'test_helper'

class ContactsControllerTest < ActionController::TestCase

	#	no subject_id
	assert_no_route(:get,:index)

	#	no route
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)
	assert_no_route(:get,:show,:id => 0)
	assert_no_route(:get,:edit,:id => 0)
	assert_no_route(:put,:update,:id => 0)
	assert_no_route(:delete,:destroy,:id => 0)

%w( superuser admin editor ).each do |cu|

	test "should get contacts with #{cu} login" do
		subject = Factory(:subject)
		login_as send(cu)
		get :index, :subject_id => subject.id
		assert assigns(:subject)
		assert_response :success
		assert_template 'index'
	end

	test "should NOT get contacts with invalid subject_id and #{cu} login" do
		login_as send(cu)
		get :index, :subject_id => 0
		assert_not_nil flash[:error]
		assert_redirected_to subjects_path
	end

end


%w( interviewer reader active_user ).each do |cu|

	test "should NOT get contacts with #{cu} login" do
		subject = Factory(:subject)
		login_as send(cu)
		get :index, :subject_id => subject.id
		assert_not_nil flash[:error]
		assert_redirected_to root_path
	end

end

	test "should NOT get contacts without login" do
		subject = Factory(:subject)
		get :index, :subject_id => subject.id
		assert_redirected_to_login
	end

end
