require 'test_helper'

class StudySubjectReportsControllerTest < ActionController::TestCase

	site_administrators.each do |cu|

		test "should get control_assignment with #{cu} login" do
			login_as send(cu)
			subject = Factory(:control_study_subject)
			assert_equal 5, subject.phase
			get :control_assignment, :format => :csv
			assert_response :success
			assert_template 'control_assignment'
#	will this be set automatically??? hmm, let's see ... NOPE
#	must explicitly set this.  Is that necessary? Doesn't seem to be.
			assert_not_nil @response.headers['Content-Disposition']
				.match(/attachment; filename=newcontrols_.*csv/)
			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first
		end

		test "should get case_assignment with #{cu} login" do
			login_as send(cu)
			subject = Factory(:case_study_subject)
			assert_equal 5, subject.phase
			get :case_assignment, :format => :csv
			assert_response :success
			assert_template 'case_assignment'
#	will this be set automatically??? hmm, let's see ... NOPE
#	must explicitly set this.  Is that necessary? Doesn't seem to be.
			assert_not_nil @response.headers['Content-Disposition']
				.match(/attachment; filename=newcases_.*csv/)
			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT get control_assignment with #{cu} login" do
			login_as send(cu)
			get :control_assignment, :format => :csv
			assert_redirected_to root_path
		end

		test "should NOT get case_assignment with #{cu} login" do
			login_as send(cu)
			get :case_assignment, :format => :csv
			assert_redirected_to root_path
		end

	end

	test "should NOT get control_assignment without login" do
		get :control_assignment, :format => :csv
		assert_redirected_to_login
	end

	test "should NOT get case_assignment without login" do
		get :case_assignment, :format => :csv
		assert_redirected_to_login
	end

end
