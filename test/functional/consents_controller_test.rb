require 'test_helper'

class ConsentsControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get, :show)
#	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
	assert_no_route(:get,:new,:study_subject_id => 0)
	assert_no_route(:post,:create,:study_subject_id => 0)

	site_readers.each do |cu|

		test "should get consents with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'show'
		end

		test "should NOT get consents with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :show, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should get edit consent with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT get edit consent with invalid study_subject_id #{cu} login" do
			login_as send(cu)
			get :edit, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should put update consent with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id
#			assert assigns(:study_subject)
#			assert_not_nil assigns(:enrollment)
#			assert_response :success
#			assert_template 'edit'
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should NOT put update consent with invalid study_subject_id #{cu} login" do
			login_as send(cu)
			put :update, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get consents with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get edit consent with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT put update consent with #{cu} login" do
			study_subject = Factory(:enrollment).study_subject
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get consents without login" do
		study_subject = Factory(:enrollment).study_subject
		get :show, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get edit consent without login" do
		study_subject = Factory(:enrollment).study_subject
		get :edit, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT put update consent without login" do
		study_subject = Factory(:enrollment).study_subject
		put :update, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

end
