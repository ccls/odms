require 'test_helper'

class ControlsControllerTest < ActionController::TestCase

#	ASSERT_ACCESS_OPTIONS = { 
##		:actions => [:new,:show],
#		:actions => [:new],
#		:method_for_create => :create_case_control_study_subject
#	}
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login
#	assert_access_with_https
#	assert_no_access_with_http


#	controls is now a nested route 
#	/case/:case_id/controls	<- really.  what for?
#	/case/:case_id/controls/new
#	/case/:case_id/controls/(create)


	site_editors.each do |cu|

		test "should get new control with case_id, matching candidate and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			get :new, :case_id => case_study_subject.id
			assert_nil flash[:error]
			assert_redirected_to edit_candidate_control_path(candidate)
		end

		test "should NOT get new control with case_id, no matching candidate and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_study_subject
			get :new, :case_id => case_study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to case_path(case_study_subject)
		end

		test "should NOT get new control with #{cu} login and invalid case_id" do
			login_as send(cu)
			get :new, :case_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end

		test "should NOT get new control with #{cu} login and non-case study_subject" do
			login_as send(cu)
			study_subject = create_study_subject
			get :new, :case_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end


#		test "should create new control with #{cu} login" do
#			login_as send(cu)
#			case_study_subject = create_case_study_subject
#			post :create, :case_id => case_study_subject.id
#			assert_nil flash[:error]
#			assert_redirected_to case_path(case_study_subject)
##	doesn't do anything, just a placeholder for now
#pending
#		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new control with case_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_study_subject
			get :new, :case_id => case_study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get new control with case_id and without login" do
		case_study_subject = create_case_study_subject
		get :new, :case_id => case_study_subject.id
		assert_redirected_to_login
	end

end
