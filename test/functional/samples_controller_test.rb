require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Sample',
		:actions => [:edit,:update,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample
	}
	def factory_attributes(options={})
		# No attributes from Factory yet (what does this mean????)
		Factory.attributes_for(:sample,{
			:sample_type_id => Factory(:sample_type).id,
			:unit_id        => Factory(:unit).id }.merge(options))
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_access_with_login({    :logins => site_readers, 
		:actions => [:show] })
	assert_no_access_with_login({ :logins => non_site_readers, 
		:actions => [:show] })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	#	no study_subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	site_editors.each do |cu|

		test "should get new sample with #{cu} login" <<
				" and study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert assigns(:sample)
		end

		test "should NOT get new sample with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

#		test "should get new sample wo study_subject_id and with #{cu} login" do
#			login_as send(cu)
#			get :new
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert !assigns(:study_subjects)
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and blank studyid" do
#			login_as send(cu)
#			get :new, :studyid => ''
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert assigns(:study_subjects).empty?
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and blank icf_master_id" do
#			login_as send(cu)
#			get :new, :icf_master_id => ''
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert assigns(:study_subjects).empty?
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and blank studyid and icf_master_id" do
#			login_as send(cu)
#			get :new, :studyid => '', :icf_master_id => ''
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert assigns(:study_subjects).empty?
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and studyid" do
#			login_as send(cu)
#			get :new, :studyid => '1234-A-5'
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert assigns(:study_subjects).empty?
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and icf_master_id" do
#			login_as send(cu)
#			get :new, :icf_master_id => '123456789'
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert assigns(:study_subjects).empty?
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and studyid and icf_master_id" do
#			login_as send(cu)
#			get :new, :studyid => '1234-A-5', :icf_master_id => '123456789'
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert assigns(:study_subjects).empty?
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and studyid of subject" do
#			subject = Factory(:complete_case_study_subject)
#			login_as send(cu)
#			get :new, :studyid => subject.studyid
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and icf_master_id of subject" do
#			subject = Factory(:complete_case_study_subject)
#			Factory(:icf_master_id, :icf_master_id => '123456789' )
#			subject.assign_icf_master_id
#			login_as send(cu)
#			get :new, :icf_master_id => subject.icf_master_id
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#
#		end
#
#		test "should get new sample wo study_subject_id and with #{cu} login" <<
#				" and studyid and icf_master_id of subject" do
#
#			s1 = Factory(:complete_case_study_subject)
#			Factory(:icf_master_id, :icf_master_id => '123456789' )
#			s1.assign_icf_master_id
#			s2 = Factory(:complete_case_study_subject)
#
#			login_as send(cu)
#			get :new, :studyid => s2.studyid, :icf_master_id => s1.icf_master_id
#			assert_nil flash[:error]
#			assert_response :success
#			assert_template 'new_for_subject'
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#
#		end









		test "should create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_nil flash[:error]
			assert_redirected_to sample_path(assigns(:sample))
		end

		test "should NOT create with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
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

		test "should NOT get new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end
	
	site_readers.each do |cu|

#		test "should show with kit tracking number and #{cu} login" do
#			login_as send(cu)
#			sample = Factory(:sample,
#				:sample_kit_attributes => {
#					:kit_package_attributes => {
#						:tracking_number => '1234567890'
#				}})
#			get :show, :id => sample.id
##	TODO package route and link currently disabled
#			assert_nil flash[:error]
#			assert assigns(:sample)
#			assert_response :success
#			assert_template 'show'
#		end
#
#		test "should show with sample tracking number and #{cu} login" do
#			login_as send(cu)
#			sample = Factory(:sample,
#				:sample_kit_attributes => {
#					:sample_package_attributes => {
#						:tracking_number => '1234567890'
#				}})
#			get :show, :id => sample.id
##	TODO package route and link currently disabled
#			assert_nil flash[:error]
#			assert assigns(:sample)
#			assert_response :success
#			assert_template 'show'
#		end

		test "should get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert assigns(:samples)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get index with #{cu} login and invalid study_subject_id" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end
	
		test "should get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
			assert_template 'dashboard'
		end
	
		test "should get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_response :success
			assert_template 'find'
		end
	
		test "should get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_response :success
			assert_template 'followup'
		end
	
		test "should get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_response :success
			assert_template 'reports'
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end
	
		test "should NOT get dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
		test "should NOT get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_redirected_to root_path
		end
	
		test "should NOT get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_redirected_to root_path
		end
	
		test "should NOT get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_redirected_to root_path
		end
	
	end

	test "should NOT get index without login and valid study_subject_id" do
		study_subject = Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end
	
	test "should NOT get dashboard without login" do
		get :dashboard
		assert_redirected_to_login
	end
	
	test "should NOT get find without login" do
		get :find
		assert_redirected_to_login
	end
	
	test "should NOT get followup without login" do
		get :followup
		assert_redirected_to_login
	end
	
	test "should NOT get reports without login" do
		get :reports
		assert_redirected_to_login
	end
	
	test "should NOT get new sample without login" do
		study_subject = Factory(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = Factory(:study_subject)
		post :create, :study_subject_id => study_subject.id,
			:sample => factory_attributes
		assert_redirected_to_login
	end

end
