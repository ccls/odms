require 'test_helper'

class StudySubjectReportsControllerTest < ActionController::TestCase

	%w( control_assignment ).each do |action|

		site_administrators.each do |cu|

			test "should get #{action} with #{cu} login" do
				login_as send(cu)
				subject = Factory(:control_study_subject)
				assert_equal 5, subject.phase
				get action, :format => :csv
				assert_response :success
				assert_template action
#	will this be set automatically??? hmm, let's see ... NOPE
#	must explicitly set this.  Is that necessary? Doesn't seem to be.
				assert_not_nil @response.headers['Content-Disposition']
					.match(/attachment; filename=newcontrols_.*csv/)
				assert  assigns(:controls)
				assert !assigns(:controls).empty?
				assert_equal 1, assigns(:controls).length
				assert_equal subject, assigns(:controls).first
			end

		end

		non_site_administrators.each do |cu|

			test "should NOT get #{action} with #{cu} login" do
				login_as send(cu)
				get action, :format => :csv
				assert_redirected_to root_path
			end

		end

		test "should NOT get #{action} without login" do
			get action, :format => :csv
			assert_redirected_to_login
		end

	end

end
