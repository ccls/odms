require 'test_helper'

class IcfMasterIdsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IcfMasterId',
		:actions => [:show,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_icf_master_id
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:icf_master_id,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login


	site_administrators.each do |cu|

		test "should get icf_master_ids and order by study_subject_id with #{cu} login" do
			login_as send(cu)
			ici1,ici2,ici3 = 3.times.collect{|i| FactoryGirl.create(:icf_master_id, :study_subject_id => i ) }
			get :index, :order => :study_subject_id
			assert_response :success
			assert_template 'index'
			assert assigns(:icf_master_ids)
			assert !assigns(:icf_master_ids).empty?
			assert_equal 3, assigns(:icf_master_ids).length
			assert_equal [ici1,ici2,ici3], assigns(:icf_master_ids)
		end

		test "should get icf_master_ids and order by study_subject_id asc with #{cu} login" do
			login_as send(cu)
			ici1,ici2,ici3 = 3.times.collect{|i| FactoryGirl.create(:icf_master_id, :study_subject_id => i ) }
			get :index, :order => :study_subject_id, :dir => :asc
			assert_response :success
			assert_template 'index'
			assert assigns(:icf_master_ids)
			assert !assigns(:icf_master_ids).empty?
			assert_equal 3, assigns(:icf_master_ids).length
			assert_equal [ici1,ici2,ici3], assigns(:icf_master_ids)
		end

		test "should get icf_master_ids and order by study_subject_id desc with #{cu} login" do
			login_as send(cu)
			ici1,ici2,ici3 = 3.times.collect{|i| FactoryGirl.create(:icf_master_id, :study_subject_id => i ) }
			get :index, :order => :study_subject_id, :dir => :desc
			assert_response :success
			assert_template 'index'
			assert assigns(:icf_master_ids)
			assert !assigns(:icf_master_ids).empty?
			assert_equal 3, assigns(:icf_master_ids).length
			assert_equal [ici1,ici2,ici3], assigns(:icf_master_ids).reverse
		end

	end

end
