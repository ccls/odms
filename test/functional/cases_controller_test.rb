require 'test_helper'

class CasesControllerTest < ActionController::TestCase
#
#	site_editors.each do |cu|
#
#		test "should get index with #{cu} login" do
#			login_as send(cu)
#			get :index
#			assert_nil assigns(:study_subject)
#			assert_response :success
#			assert_template 'index'
#		end
#
#		test "should return nothing without matching patid and #{cu} login" do
#			login_as send(cu)
#			get :index, :q => 'NOPE'
#			assert_nil assigns(:study_subject)
#			assert_response :success
#			assert_template 'index'
#			assert_not_nil flash[:error]
#			assert_match /No case study_subject found with given:NOPE/,
#				flash[:error]
#		end
#
#		test "should return nothing without matching icf master id and #{cu} login" do
#			login_as send(cu)
#			get :index, :q => 'donotmatch'
#			assert_nil assigns(:study_subject)
#			assert_response :success
#			assert_template 'index'
#			assert_not_nil flash[:error]
#			assert_match /No case study_subject found with given:donotmatch/,
#				flash[:error]
#		end
#
#		test "should return case study_subject with matching patid and #{cu} login" do
#			login_as send(cu)
#			case_study_subject = Factory(:complete_case_study_subject)
#			get :index, :q => case_study_subject.patid
#			assert_not_nil assigns(:study_subject)
#			assert_equal case_study_subject, assigns(:study_subject)
#			assert_response :success
#			assert_template 'index'
#		end
#
#		test "should return case study_subject with matching patid missing" <<
#				" leading zeroes and #{cu} login" do
#			login_as send(cu)
#			case_study_subject = Factory(:complete_case_study_subject)
#			# case_study_subject.patid should be a small 4-digit string
#			#   with leading zeroes. (probably 0001). Remove them before submit.
#			patid = case_study_subject.patid.to_i
#			assert patid < 1000,
#				'Expected auto-generated patid to be less than 1000 for this test'
#			get :index, :q => patid
#			assert_not_nil assigns(:study_subject)
#			assert_equal case_study_subject, assigns(:study_subject)
#			assert_response :success
#			assert_template 'index'
#		end
#
#		test "should return case study_subject with matching icf master id and #{cu} login" do
#			login_as send(cu)
#			case_study_subject = Factory(:complete_case_study_subject,
#				:icf_master_id => '12345')
#			get :index, :q => case_study_subject.icf_master_id
#			assert_not_nil assigns(:study_subject)
#			assert_equal case_study_subject, assigns(:study_subject)
#			assert_response :success
#			assert_template 'index'
#		end
#
#	end
#
#
#	non_site_editors.each do |cu|
#
#		test "should NOT get index with #{cu} login" do
#			login_as send(cu)
#			get :index
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end
#
#	end
#
#
##	no login ...
#
#	test "should NOT get index without login" do
#		get :index
#		assert_redirected_to_login
#	end
#
end
__END__
