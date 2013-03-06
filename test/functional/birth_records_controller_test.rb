require 'test_helper'

class BirthRecordsControllerTest < ActionController::TestCase

	#	no route
	assert_no_route(:get,:index)

	#	no study_subject_id (has_one so no id needed)
	assert_no_route(:get,:show)     
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

	#	All nested routes, so common class-level assertions won't work

	site_administrators.each do |cu|

		test "should show birth_record with birth record and #{cu} login" do
			study_subject = Factory(:study_subject)
			birth_datum = Factory(:birth_datum,
				:study_subject => study_subject )
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should show birth_record with no birth record and #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT show birth_record with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT show birth_record with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT show birth_record without login" do
		study_subject = Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

end
