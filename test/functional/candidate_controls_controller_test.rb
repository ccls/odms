require 'test_helper'

class CandidateControlsControllerTest < ActionController::TestCase

	site_editors.each do |cu|

		test "should get edit with #{cu} login" do
			login_as send(cu)
#			case_study_subject = create_case_study_subject
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.reload.patid)
#			get :edit, :id => candidate.id
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'edit'
pending
		end

		test "should NOT get edit with #{cu} login and invalid id" do
			login_as send(cu)
#			get :edit, :id => 0
#			assert_not_nil flash[:error]
#			assert_redirected_to cases_path
		end

		test "should NOT get edit with #{cu} login and no case" do
			login_as send(cu)
			candidate = create_candidate_control
#			get :edit, :id => candidate.id
#			assert_not_nil flash[:error]
#			assert_redirected_to cases_path
pending
		end

		test "should put update with #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#			put :update, :id => candidate.id, :candidate_control => {}
pending
		end

		test "should NOT put update with #{cu} login and invalid id" do
			login_as send(cu)
			put :update, :id => 0, :candidate_control => {}
pending
		end

		test "should NOT put update with #{cu} login and no case" do
			login_as send(cu)
			candidate = create_candidate_control
#			put :update, :id => candidate.id, :candidate_control => {}
pending
		end

		test "should NOT put update with #{cu} login and invalid candidate" do
			login_as send(cu)
			case_study_subject = create_case_study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			CandidateControl.any_instance.stubs(:valid?).returns(false)
#			put :update, :id => candidate.id, :candidate_control => {}
pending
		end

		test "should NOT put update with #{cu} login and candidate save fails" do
			login_as send(cu)
			case_study_subject = create_case_study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			CandidateControl.any_instance.stubs(:create_or_update).returns(false)
#			put :update, :id => candidate.id, :candidate_control => {}
pending
		end

		#	same as invalid candidate, but more explicit and obvious
		test "should NOT put update with #{cu} login and rejected without reason" do
			login_as send(cu)
			case_study_subject = create_case_study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#			put :update, :id => candidate.id, :candidate_control => {
#				:reject_candidate => true,
#				:rejection_reason => '' }
pending
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get edit with #{cu} login" do
			login_as send(cu)
			candidate = create_candidate_control
			get :edit, :id => candidate.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT put update with #{cu} login" do
			login_as send(cu)
			candidate = create_candidate_control
			put :update, :id => candidate.id, :candidate_control => {}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	#	not logged in
	test "should NOT get edit without login" do
		candidate = create_candidate_control
		get :edit, :id => candidate.id
		assert_redirected_to_login
	end

	test "should NOT put update without login" do
		candidate = create_candidate_control
		put :update, :id => candidate.id, :candidate_control => {}
		assert_redirected_to_login
	end

end
