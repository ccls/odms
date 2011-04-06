require 'test_helper'

class Interview::SubjectsControllerTest < ActionController::TestCase

	setup :create_home_exposure_with_subject

	ASSERT_ACCESS_OPTIONS = {
		:actions => [:index]
	}
	assert_access_with_login({ 
		:logins => [:superuser,:admin,:reader,:editor] })
	assert_no_access_with_login({ 
		:logins => [:active_user] })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http


%w( superuser admin reader editor ).each do |cu|

	test "should download csv with #{cu} login" do
		login_as send(cu)
		get :index, :commit => 'download'
		assert_response :success
		assert_not_nil @response.headers['Content-disposition'].match(/attachment;.*csv/)
	end

	test "should show interview/subjects " <<
			"with invalid hx interview subject " <<
			"with #{cu} login" do
		subject = create_hx_subject
		login_as send(cu)
		get :show, :id => subject.id

		assert_response :success

#		assert_not_nil flash[:error]
#		assert_redirected_to interview_subjects_path
	end

	test "should show interview/subjects " <<
			"with valid hx interview subject " <<
			"with #{cu} login" do
		subject = create_hx_interview_subject	#	doesn't really matter
		login_as send(cu)
		get :show, :id => subject.id

		assert_response :success

#		assert_nil flash[:error]
#		assert_redirected_to interview_path(subject.hx_interview)
	end

end

%w( active_user ).each do |cu|

	test "should NOT download csv with #{cu} login" do
		login_as send(cu)
		get :index, :commit => 'download'
		assert_redirected_to root_path
		assert_not_nil flash[:error]
	end

end

	test "should NOT download csv without login" do
		get :index, :commit => 'download'
		assert_redirected_to_login
	end

end
