require 'test_helper'

class ControlsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:actions => [:new,:show],
		:method_for_create => :create_case_control_study_subject
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_editors.each do |cu|

		test "should return nothing without matching patid and #{cu} login" do
			login_as send(cu)
			get :new, :patid => 'donotmatchpatid'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return case study_subject with matching patid and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_control_study_subject
			get :new, :patid => case_study_subject.patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT show related study_subjects with #{cu} login and invalid id" do
			login_as send(cu)
			get :show, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to new_control_path
		end

		test "should NOT show related study_subjects with #{cu} login and non-case study_subject" do
			login_as send(cu)
			study_subject = create_study_subject
			get :show, :id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to new_control_path
		end

	end

#	non_site_editors.each do |cu|
#
#	end

#	no login ...
#
#

end
