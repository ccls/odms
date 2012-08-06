require 'test_helper'

class ChartsControllerTest < ActionController::TestCase

	%w( samples_locations samples_projects
		samples_sample_types samples_sample_temperatures
		enrollments vital_statuses vital_statuses_pie
		subject_types subject_types_pie case_control_types
		case_control_types_pie childidwho is_eligible
		consented 
		phase_5_case_enrollment_by_month
		phase_5_case_enrollment case_enrollment blood_bone_marrow
		subject_types_by_phase vital_statuses_by_phase
		).each do |action|

#
#	case_enrollment and phase_5_case_enrollment may fail on a first
#	run due to non-existant projects which cause non-existant
#	hex_* search keys.
#

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
		end

	end

end
