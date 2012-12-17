require 'test_helper'

class ControlsControllerTest < ActionController::TestCase

	#	Too complex for common assertions

	site_editors.each do |cu|

#
#	The new control link from the menu goes to the new control page.
#	Searching for a case via the patid will then return you to the
#	new control page with the case info if any found.
#	Clicking continue will take you to the related subjects page.
#	On the related subjects page, there is a add control link
#	which will take you to the create control action.
#

		test "should get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return nothing without matching patid and #{cu} login" do
			login_as send(cu)
			get :new, :q => 'NOPE'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:NOPE/,
				flash[:error]
		end

		test "should return nothing without matching icf master id and #{cu} login" do
			login_as send(cu)
			get :new, :q => 'donotmatch'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:donotmatch/,
				flash[:error]
		end

		test "should return case study_subject with matching patid and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			get :new, :q => case_study_subject.patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return case study_subject with matching patid missing" <<
				" leading zeroes and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			# case_study_subject.patid should be a small 4-digit string
			#   with leading zeroes. (probably 0001). Remove them before submit.
			patid = case_study_subject.patid.to_i
			assert patid < 1000,
				'Expected auto-generated patid to be less than 1000 for this test'
			get :new, :q => patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should return case study_subject with matching icf master id and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject,
				:icf_master_id => '12345')
			get :new, :q => case_study_subject.icf_master_id
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

	



		test "should get new control with case_id, matching candidate and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			post :create, :case_id => case_study_subject.id
			assert_nil flash[:error]
			assert_redirected_to edit_candidate_control_path(candidate)
		end

		test "should NOT get new control with case_id, no matching candidate and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:case_study_subject)
			post :create, :case_id => case_study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_related_subjects_path(case_study_subject)
		end

		test "should NOT get new control with #{cu} login and invalid case_id" do
			login_as send(cu)
			post :create, :case_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to new_control_path
		end

		test "should NOT get new control with #{cu} login and non-case study_subject" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			post :create, :case_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to new_control_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new control with case_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:case_study_subject)
			post :create, :case_id => case_study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get new without login" do
		get :new
		assert_redirected_to_login
	end

	test "should NOT get new control with case_id and without login" do
		case_study_subject = Factory(:case_study_subject)
		post :create, :case_id => case_study_subject.id
		assert_redirected_to_login
	end

end
__END__
