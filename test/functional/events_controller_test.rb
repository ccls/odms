require 'test_helper'

class EventsControllerTest < ActionController::TestCase

	#	no subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
	assert_no_route(:get,:new,:subject_id => 0)
	assert_no_route(:post,:create,:subject_id => 0)

%w( superuser admin editor interviewer reader ).each do |cu|

	test "should get events with #{cu} login" do
		subject = Factory(:subject)
		login_as send(cu)
		get :index, :subject_id => subject.id
		assert assigns(:subject)
		assert_response :success
		assert_template 'index'
	end

	test "should get events with #{cu} login and hx subject" do
		subject = create_hx_subject
		login_as send(cu)
		get :index, :subject_id => subject.id
		assert assigns(:subject)
		assert_response :success
		assert_template 'index'
	end

	test "should NOT get events with invalid subject_id " <<
		"and #{cu} login" do
		login_as send(cu)
		get :index, :subject_id => 0
		assert_not_nil flash[:error]
		assert_redirected_to subjects_path
	end

end


%w( active_user ).each do |cu|

	test "should NOT get events with #{cu} login" do
		subject = create_hx_subject
		login_as send(cu)
		get :index, :subject_id => subject.id
		assert_not_nil flash[:error]
		assert_redirected_to root_path
	end

end

	test "should NOT get events without login" do
		subject = create_hx_subject
		get :index, :subject_id => subject.id
		assert_redirected_to_login
	end

end
