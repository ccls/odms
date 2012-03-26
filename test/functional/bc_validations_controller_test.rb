require 'test_helper'

class BcValidationsControllerTest < ActionController::TestCase
#
#	ASSERT_ACCESS_OPTIONS = { 
##		:model => 'StudySubject',
#		:actions => [:index,:show],
#		:method_for_create => :create_case_study_subject
#	}
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login
##	assert_access_with_https
##	assert_no_access_with_http
#
#	site_editors.each do |cu|
#
#		test "should NOT show bc_validation with #{cu} login and non-case study_subject" do
#			login_as send(cu)
#			study_subject = Factory(:study_subject)
#			get :show, :id => study_subject.id
#			assert_not_nil flash[:error]
#			assert_redirected_to bc_validations_path
#		end
#
#		test "should show bc_validation with candidate controls and #{cu} login" do
#			login_as send(cu)
#			study_subject = Factory(:complete_case_study_subject)
#			get :show, :id => study_subject.id
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'show'
#			assert_not_nil assigns(:controls)	#	although is probably empty
#		end
#
#	end
#
end
