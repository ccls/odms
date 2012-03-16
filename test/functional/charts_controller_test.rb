require 'test_helper'

class ChartsControllerTest < ActionController::TestCase

#	ChartsController.action_methods.each do |action|

	%w( enrollments vital_statuses vital_statuses_pie
		subject_types subject_types_pie case_control_types
		case_control_types_pie childidwho is_eligible
		consented ).each do |action|

		all_test_roles.each do |cu|

			test "should get #{action} with #{cu} login" do
				login_as send(cu)
				get action, :format => 'json'
				assert_response :success
			end

		end

		test "should NOT get #{action} without login" do
			get action, :format => 'json'
			#	json requests do not redirect, apparently
			assert @response.body.blank?
			assert_response :unauthorized
#			assert_redirected_to_login
		end

	end

end
