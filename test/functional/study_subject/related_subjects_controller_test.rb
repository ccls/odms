require 'test_helper'

class StudySubject::RelatedSubjectsControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::RelatedSubjectsController

	site_editors.each do |cu|

		test "should get index with case study_subject_id and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'index'
		end

		test "should get index with control study_subject_id and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_control_study_subject)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'index'
		end

		test "should get index with mother study_subject_id and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_mother_study_subject)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'index'
		end

		test "should get index with #{cu} login and include rejected controls" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			candidate = FactoryGirl.create(:candidate_control,{
				:related_patid    => study_subject.patid,
				:reject_candidate => true,
				:rejection_reason => 'something' })
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'index'
			assert !assigns(:rejected_controls).empty?
			assert  assigns(:unrejected_controls).empty?
		end

		test "should get index with #{cu} login and with unrejected controls" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:complete_case_study_subject)
			candidate = FactoryGirl.create(:candidate_control,{
				:related_patid    => study_subject.patid })
			get :index, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'index'
			assert  assigns(:rejected_controls).empty?
			assert !assigns(:unrejected_controls).empty?
		end

		test "should NOT get index related study_subjects with #{cu} login and invalid study_subject_id" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get index with study_subject_id and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get index without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

end
