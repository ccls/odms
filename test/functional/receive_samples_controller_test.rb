require 'test_helper'

class ReceiveSamplesControllerTest < ActionController::TestCase

#	I don't think that any of the auto tests will work.
#	Well, 'new' might, but there are a lot of other
#	variables to test.

#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Sample',
#		:actions => [:new,:create],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_sample
#	}
	def factory_attributes(options={})
#			:sample_source
#			:storage_temperature
#			:collected_at
#			:shipped_at
#			:received_by_ccls_at
		#	Being more explicit to reflect what is actually on the form
		{
			:project_id     => Project['ccls'].id,
			:sample_type_id => Factory(:sample_type).id
		}.merge(options)
	end

#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login
#	assert_access_with_https
#	assert_no_access_with_http

#	assert_no_route(:get,:index)
#	assert_no_route(:get, :show)
#	assert_no_route(:get, :edit)
#	assert_no_route(:put, :update)
#	assert_no_route(:delete, :destroy)

	site_editors.each do |cu|

		test "should get new receive sample wo study_subject_id and with #{cu} login" do
			login_as send(cu)
			get :new
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert !assigns(:study_subjects)
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and blank studyid" do
			login_as send(cu)
			get :new, :studyid => ''
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and blank icf_master_id" do
			login_as send(cu)
			get :new, :icf_master_id => ''
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and blank studyid and icf_master_id" do
			login_as send(cu)
			get :new, :studyid => '', :icf_master_id => ''
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and nonexistant studyid" do
			login_as send(cu)
			get :new, :studyid => '1234-A-5'
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and nonexistant icf_master_id" do
			login_as send(cu)
			get :new, :icf_master_id => '123456789'
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and nonexistant studyid and nonexistant icf_master_id" do
			login_as send(cu)
			get :new, :studyid => '1234-A-5', :icf_master_id => '123456789'
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:warn]
			assert_match /No Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and studyid and icf_master_id of subjects" do

			s1 = Factory(:complete_case_study_subject)
			Factory(:icf_master_id, :icf_master_id => '123456789' )
			s1.assign_icf_master_id
			s2 = Factory(:complete_case_study_subject)

			login_as send(cu)
			get :new, :studyid => s2.studyid, :icf_master_id => s1.icf_master_id
			assert_not_nil flash[:warn]
			assert_match /Multiple Study Subjects Found/, flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
		end


#	SINGLE STUDY SUBJECT FOUND

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and studyid of subject" do
			study_subject = Factory(:complete_case_study_subject)
			login_as send(cu)
			get :new, :studyid => study_subject.studyid
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal study_subject, assigns(:study_subject)
			assert assigns(:sample)
		end

		test "should get new receive sample wo study_subject_id and with #{cu} login" <<
				" and icf_master_id of subject" do
			study_subject = Factory(:complete_case_study_subject)
			Factory(:icf_master_id, :icf_master_id => '123456789' )
			study_subject.assign_icf_master_id
			login_as send(cu)
			get :new, :icf_master_id => study_subject.icf_master_id
			assert_nil flash[:warn]
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal study_subject, assigns(:study_subject)
			assert assigns(:sample)
		end

		test "should get new receive sample with #{cu} login" <<
				" and study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal study_subject, assigns(:study_subject)
			assert assigns(:sample)
		end


#	TODO what if subject has no enrollments
#	TODO what if subject has no consented enrollments
#	TODO what if subject is mother




		test "should create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to new_receive_sample_path
		end

		test "should NOT create with #{cu} login " <<
				"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create with #{cu} login " <<
				"and save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new receive sample with #{cu} login" do
			login_as send(cu)
			get :new
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',0){
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get new receive sample without login" do
		get :new
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = Factory(:study_subject)
		assert_difference('Sample.count',0){
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
		}
		assert_redirected_to_login
	end

end
