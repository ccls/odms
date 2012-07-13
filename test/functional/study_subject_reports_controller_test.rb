require 'test_helper'

class StudySubjectReportsControllerTest < ActionController::TestCase

	%w( control_assignment ).each do |action|

		site_administrators.each do |cu|

			test "should get #{action} with #{cu} login" do
				login_as cu
				get action, :format => :csv
				assert_response :success
				assert_template action

assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
assert assigns(:controls)
assert !assigns(:controls).empty?
			end

		end
		non_site_administrators.each do |cu|

			test "should NOT get #{action} with #{cu} login" do
				login_as cu
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
