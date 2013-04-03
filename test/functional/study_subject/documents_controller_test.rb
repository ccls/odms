require 'test_helper'

class StudySubject::DocumentsControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
	assert_no_route(:get,:new,:study_subject_id => 0)
	assert_no_route(:post,:create,:study_subject_id => 0)


#	ONLY INDEX


	site_readers.each do |cu|

		test "should get documents with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get documents with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get documents with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get documents without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

end
