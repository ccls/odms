require 'test_helper'
require 'raf_test_helper'

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
#		Factory.attributes_for(:study_subject,options)
#	end
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login


#
#	"new" will now be a full form
#	"create" will no longer redirect to a RAF
#	"show" will be added
#	"edit" will be added
#	"update" will be added
#
#	possibly be able to use "generic" stuff
#

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
			get :index, :q => 'NOPE'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:NOPE/,
				flash[:error]
		end

		test "should return nothing without matching icf master id and #{cu} login" do
			login_as send(cu)
			get :index, :q => 'donotmatch'
			assert_nil assigns(:study_subject)
			assert_response :success
			assert_template 'index'
			assert_not_nil flash[:error]
			assert_match /No case study_subject found with given:donotmatch/,
				flash[:error]
		end

		test "should return case study_subject with matching patid and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject)
			get :index, :q => case_study_subject.patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
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
			get :index, :q => patid
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should return case study_subject with matching icf master id and #{cu} login" do
			login_as send(cu)
			case_study_subject = Factory(:complete_case_study_subject,
				:icf_master_id => '12345')
			get :index, :q => case_study_subject.icf_master_id
			assert_not_nil assigns(:study_subject)
			assert_equal case_study_subject, assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end








		test "should get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil assigns(:study_subject)
			assert_response :success
			assert_template 'new'
		end





#		test "should post new case and redirect to waivered with #{cu} login" do
#			login_as send(cu)
#			hospital = Hospital.active.waivered.first
#			post :create, { "hospital_id"=> hospital.id }					#		TODO will need changed
#			assert_redirected_to new_waivered_path("study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> hospital.organization_id }})
#		end
#
#		test "should post new case and redirect to nonwaivered with #{cu} login" do
#			login_as send(cu)
#			hospital = Hospital.active.nonwaivered.first
#			post :create, { "hospital_id"=> hospital.id }					#		TODO will need changed
#			assert_redirected_to new_nonwaivered_path("study_subject"=>{"patient_attributes"=>{
#				"organization_id"=> hospital.organization_id }})
#		end
#
#		test "should not post new case without hospital_id and #{cu} login" do
#			login_as send(cu)
#			post :create
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end
#
#		test "should not post new case without valid hospital_id and #{cu} login" do
#			login_as send(cu)
#			post :create, { "hospital_id"=> '0' }					#		TODO will need changed
#			assert_not_nil flash[:error]
#			assert_redirected_to new_case_path
#		end



		test "should create new case with valid waivered subject #{cu} login" do
			login_as send(cu)
			minimum_waivered_successful_creation
		end

		test "should create new case with valid nonwaivered subject #{cu} login" do
			login_as send(cu)
			minimum_nonwaivered_successful_creation
		end

		test "should NOT create new case with invalid subject #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_all_differences(0) do
				post :create, minimum_nonwaivered_form_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create new case with failed subject save #{cu} login" do
			login_as send(cu)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_all_differences(0) do
				post :create, minimum_nonwaivered_form_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end





		test "should show case with valid case id #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'show'
		end

		test "should NOT show control with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT show mother with #{cu} login" do
			study_subject = Factory(:mother_study_subject)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT show with invalid id #{cu} login" do
			login_as send(cu)
			get :show, :id => 0
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should edit case with #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit mother with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT edit control with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			get :edit, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT edit with invalid id #{cu} login" do
			login_as send(cu)
			get :edit, :id => 0
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should update case with #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_nil flash[:error]
			assert_redirected_to case_path(study_subject)
		end

		test "should NOT update mother with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT update control with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			put :update, :id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT update with invalid id #{cu} login" do
			login_as send(cu)
			put :update, :id => 0
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		#
		#	As they are not required on creation, editting could create.
		#

		test "should update and create address with #{cu} login" do
pending
		end

		test "should update and create phone number with #{cu} login" do
pending
		end


	end

	non_site_editors.each do |cu|

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT post new with #{cu} login" do
			login_as send(cu)
			post :create	#, {"hospital_id"=>"0"}					#		TODO will need changed
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT show with #{cu} login" do
			login_as send(cu)
			get :show, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			login_as send(cu)
			get :edit, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			login_as send(cu)
			put :update, :id => 0							#	TODO MAY need to add attributes (doubt it)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT get new without login" do
		get :new
		assert_redirected_to_login
	end

	test "should NOT post new without login" do
		post :create	#, {"hospital_id"=>"0"}					#		TODO will need changed
		assert_redirected_to_login
	end

	test "should NOT show without login" do
		get :show, :id => 0
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		get :edit, :id => 0
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		put :update, :id => 0						#	TODO MAY need to add attributes (doubt it)
		assert_redirected_to_login
	end

end
