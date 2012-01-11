require 'test_helper'

class CasesControllerTest < ActionController::TestCase

#
#	This is too unconventional for any of this to work.
#
#	ASSERT_ACCESS_OPTIONS = { 
#		:model   => 'StudySubject',
#		:actions => [:new,:show,:index],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_study_subject
#	}
#	def factory_attributes(options={})
#		Factory.attributes_for(:study_subject,{
#			'identifier_attributes' => Factory.attributes_for(:identifier)
#		}.merge(options))
#	end
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login
#	assert_access_with_https
#	assert_no_access_with_http


	site_editors.each do |cu|

		test "should get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should return nothing without matching patid and #{cu} login" do
			login_as send(cu)
			get :index, :patid => 'donotmatchpatid'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should return case study_subject with matching patid and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_control_study_subject
			get :index, :patid => case_study_subject.patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

#		test "should get show with id and #{cu} login" do
#			login_as send(cu)
#			case_study_subject = create_case_control_study_subject
#			get :show, :id => case_study_subject.id
#			assert_response :success
#			assert_template 'show'
#		end
#
#		test "should get show with #{cu} login and include rejected controls" do
#			login_as send(cu)
#			case_study_subject = create_case_control_study_subject
#			candidate = create_candidate_control(
#				:related_patid    => case_study_subject.patid,
#				:reject_candidate => true,
#				:rejection_reason => 'something' )
#			get :show, :id => case_study_subject.id
#			assert_response :success
#			assert_template 'show'
#			assert !assigns(:rejected_controls).empty?
#		end
#
#		test "should NOT show related study_subjects with #{cu} login and invalid id" do
#			login_as send(cu)
#			get :show, :id => 0
#			assert_not_nil flash[:error]
#			assert_redirected_to cases_path
#		end
#
#		test "should NOT show related study_subjects with #{cu} login and non-case study_subject" do
#			login_as send(cu)
#			study_subject = create_study_subject
#			get :show, :id => study_subject.id
##			assert_not_nil flash[:error]
##			assert_redirected_to study_subject_path(assigns(:study_subject).id)
#			assert_nil flash[:error]
#			assert_match /for case subjects only/,
#				@response.body
#			assert_template 'not_case'
#		end

		test "should get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end

		test "should post new case and redirect to waivered with #{cu} login" do
			login_as send(cu)
			hospital = Hospital.find_by_has_irb_waiver(true)
#			post :create, {"study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> hospital.organization_id }}}
			post :create, { "hospital_id"=> hospital.id }
			assert_redirected_to new_waivered_path("study_subject"=>{"patient_attributes"=>{
				"organization_id"=> hospital.organization_id }})
		end

		test "should post new case and redirect to nonwaivered with #{cu} login" do
			login_as send(cu)
			hospital = Hospital.find_by_has_irb_waiver(false)
#			post :create, {"study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> hospital.organization_id }}}
			post :create, { "hospital_id"=> hospital.id }
			assert_redirected_to new_nonwaivered_path("study_subject"=>{"patient_attributes"=>{
				"organization_id"=> hospital.organization_id }})
		end

		test "should not post new case without hospital_id and #{cu} login" do
			login_as send(cu)
			post :create
			assert_not_nil flash[:error]
			assert_redirected_to new_case_path
		end

		test "should not post new case without valid hospital_id and #{cu} login" do
			login_as send(cu)
			post :create, { "hospital_id"=> '0' }
			assert_not_nil flash[:error]
			assert_redirected_to new_case_path
		end

#		test "should not post new case without patient_attributes and #{cu} login" do
#			login_as send(cu)
#			post :create, {"study_subject"=>{}}
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end
#
#		test "should not post new case without organization_id and #{cu} login" do
#			login_as send(cu)
#			post :create, {"study_subject"=>{"patient_attributes"=>{}}}
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end
#
#		test "should not post new case without valid organization_id and #{cu} login" do
#			login_as send(cu)
#			post :create, {"study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> '0' }}}
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end

	end

	non_site_editors.each do |cu|

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

#		test "should NOT get show with id and #{cu} login" do
#			login_as send(cu)
#			study_subject = create_study_subject
#			get :show, :id => study_subject.id
#			assert_not_nil flash[:error]
#			assert_redirected_to root_path
#		end

		test "should NOT get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT post new with #{cu} login" do
			login_as send(cu)
#			post :create, {"study_subject"=>{"patient_attributes"=>{"organization_id"=>"0"}}}
			post :create, {"hospital_id"=>"0"}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

#	test "should NOT get show without login" do
#		study_subject = create_study_subject
#		get :show, :id => study_subject.id
#		assert_redirected_to_login
#	end

	test "should NOT get new without login" do
		get :new
		assert_redirected_to_login
	end

	test "should NOT post new without login" do
#		post :create, {"study_subject"=>{"patient_attributes"=>{"organization_id"=>"0"}}}
		post :create, {"hospital_id"=>"0"}
		assert_redirected_to_login
	end

end
