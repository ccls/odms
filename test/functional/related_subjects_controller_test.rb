require 'test_helper'

class RelatedSubjectsControllerTest < ActionController::TestCase

	site_editors.each do |cu|

		test "should get show with case id and #{cu} login" do
			login_as send(cu)
#			study_subject = create_case_control_study_subject
			study_subject = Factory(:complete_case_study_subject)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
		end

		test "should get show with control id and #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:complete_control_study_subject)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
		end

		test "should get show with mother id and #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:complete_mother_study_subject)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
		end

		test "should get show with #{cu} login and include rejected controls" do
			login_as send(cu)
			study_subject = Factory(:complete_case_study_subject)
			candidate = create_candidate_control(
				:related_patid    => study_subject.patid,
				:reject_candidate => true,
				:rejection_reason => 'something' )
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
			assert !assigns(:rejected_controls).empty?
		end

		test "should NOT show related study_subjects with #{cu} login and invalid id" do
			login_as send(cu)
			get :show, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get show with id and #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :show, :id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get show without login" do
		study_subject = Factory(:study_subject)
		get :show, :id => study_subject.id
		assert_redirected_to_login
	end

end
