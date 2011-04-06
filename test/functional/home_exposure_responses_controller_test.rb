require 'test_helper'

class HomeExposureResponsesControllerTest < ActionController::TestCase

	#	no subject_id (has_one so NOT id for show)
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)
	assert_no_route(:get,:show)

	#	no route
	assert_no_route(:get,:index)
	assert_no_route(:get,:edit,:id => 0)
	assert_no_route(:put,:update,:id => 0)
#	assert_no_route(:delete,:destroy,:id => 0)

	setup :create_home_exposure_with_subject

#	setup :build_response_sets
#	def build_response_sets	#	setup
#		@rs1 = fill_out_survey(
#			:survey => Survey.find_by_access_code("home_exposure_survey"))
#		@rs1.reload
#		@rs2 = fill_out_survey(
#			:subject => @rs1.subject, 
#			:survey => @rs1.survey)
#	end

	assert_no_access_with_login [],{
		:suffix => " and invalid subject_id",
		:redirect => :home_exposure_path,
		:login => :superuser,
		:new => { :subject_id => 0 },
		:show => { :subject_id => 0 }
	}

#%w( superuser admin editor interviewer reader ).each do |cu|
#
#
##	ONLY FOR DEVELOPMENT.  THIS SHOULD PROBABLY BE REMOVED
#	test "should destroy with #{cu} login" do
#		@rs1.to_her
#		login_as send(cu)
#		delete :destroy, :subject_id => @rs1.study_subject_id
#		assert_redirected_to subject_response_sets_path(@rs1.subject)
#	end
#
#
#	test "should show new with very different response sets " <<
#		"with #{cu} login" do
#		@rs2.responses.destroy_all
#		login_as send(cu)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_response :success
#		assert_template 'new'
#	end
#
#	test "should get new with #{cu} login" do
#		login_as send(cu)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_response :success
#		assert_template 'new'
#	end
#
#	test "should create HER with #{cu} login" do
#		login_as send(cu)
#		assert_difference("HomeExposureResponse.count",1) {
#			post :create, :subject_id => @rs1.study_subject_id, 
#				:home_exposure_response => @rs1.q_and_a_codes_as_attributes
#		}
#		assert_redirected_to subject_home_exposure_response_path(
#			assigns(:subject))
#	end
#
#	test "should show with #{cu} login" do
#		@rs1.to_her
#		login_as send(cu)
#		get :show, :subject_id => @rs1.study_subject_id
#		assert_response :success
#		assert_template 'show'
#	end
#
#	test "should NOT get new with 1 response sets " <<
#		"with #{cu} login" do
#		@rs2.destroy
#		login_as send(cu)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_redirected_to home_exposure_path
#		assert_not_nil flash[:error]
#	end
#
#	test "should NOT get new with 3 response sets " <<
#		"with #{cu} login" do
#		rs3 = fill_out_survey(:subject => @rs1.subject, :survey => @rs1.survey)
#		login_as send(cu)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_redirected_to home_exposure_path
#		assert_not_nil flash[:error]
#	end
#
#	test "should NOT get new with incomplete response set " <<
#		"with #{cu} login" do
#		@rs1.update_attribute(:completed_at, nil)
#		login_as send(cu)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_redirected_to home_exposure_path
#		assert_not_nil flash[:error]
#	end
#
#	test "should NOT get new when HER already exists " <<
#		"with #{cu} login" do
#		assert_difference("HomeExposureResponse.count",1){
#			@rs1.to_her
#		}
#		login_as send(cu)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_redirected_to home_exposure_path
#		assert_not_nil flash[:error]
#	end
#
#	test "should NOT create HER without valid subject_id " <<
#		"with #{cu} login" do
#		login_as send(cu)
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => 0, 
#				:home_exposure_response => @rs1.q_and_a_codes_as_attributes
#		}
#		assert_not_nil flash[:error]
#		assert_redirected_to home_exposure_path
#	end
#
#	test "should NOT create HER without home_exposure_response " <<
#		"with #{cu} login" do
#		login_as send(cu)
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => @rs1.study_subject_id
#		}
#		assert_not_nil flash[:error]
#		assert_redirected_to home_exposure_path
#	end
#
#	test "should NOT create HER without valid home_exposure_response " <<
#		"with #{cu} login" do
#		login_as send(cu)
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => @rs1.study_subject_id, 
#				:home_exposure_response => 0
#		}
#		assert_not_nil flash[:error]
#		assert_redirected_to home_exposure_path
#	end
#
#	test "should NOT create HER when HER.create fails " <<
#		"with #{cu} login" do
#		HomeExposureResponse.any_instance.stubs(:save).returns(false)
#		login_as send(cu)
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => @rs1.study_subject_id, 
#				:home_exposure_response => @rs1.q_and_a_codes_as_attributes
#		}
#		assert_not_nil flash[:error]
#		assert_response :success
#		assert_template 'new'
#	end
#
#	test "should NOT create HER when HER already exists " <<
#		"with #{cu} login" do
#		@rs1.to_her
#		login_as send(cu)
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => @rs1.study_subject_id, 
#				:home_exposure_response => @rs1.q_and_a_codes_as_attributes
#		}
#		assert_not_nil flash[:error]
#		assert_redirected_to home_exposure_path
#	end
#
#	test "should NOT show without existing home_exposure_response " <<
#		"with #{cu} login" do
#		login_as send(cu)
#		get :show, :subject_id => @rs1.study_subject_id
#		assert_redirected_to home_exposure_path
#		assert_not_nil flash[:error]
#	end
#
#end
#
#%w( active_user ).each do |u|
#
#	test "should NOT get new with #{u} login" do
#		login_as send(u)
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_redirected_to root_path
#		assert_not_nil flash[:error]
#	end
#
#	test "should NOT create HER with #{u} login" do
#		login_as send(u)
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => @rs1.study_subject_id, 
#				:home_exposure_response => @rs1.q_and_a_codes_as_attributes
#		}
#		assert_redirected_to root_path
#		assert_not_nil flash[:error]
#	end
#
#	test "should NOT show with #{u} login" do
#		@rs1.to_her
#		login_as send(u)
#		get :show, :subject_id => @rs1.study_subject_id
#		assert_not_nil flash[:error]
#		assert_redirected_to root_path
#	end
#
#end
#
#	test "should NOT get new without login" do
#		get :new, :subject_id => @rs1.study_subject_id
#		assert_redirected_to_login
#	end
#
#	test "should NOT create HER without login" do
#		assert_difference("HomeExposureResponse.count",0) {
#			post :create, :subject_id => @rs1.study_subject_id, 
#				:home_exposure_response => @rs1.q_and_a_codes_as_attributes
#		}
#		assert_redirected_to_login
#	end
#
#	test "should NOT show without login" do
#		@rs1.to_her
#		get :show, :subject_id => @rs1.study_subject_id
#		assert_redirected_to_login
#	end

end
