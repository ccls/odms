require 'test_helper'

class BirthDataControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'BirthDatum',
		:actions => [:show,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_birth_datum
	}

	def factory_attributes(options={})
		FactoryBot.attributes_for(:birth_datum,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	site_administrators.each do |cu|

		test "should get index with order study_subject_id and dir desc "<<
				"with #{cu} login and no birth datum" do
			login_as send(cu)
			get :index, :order => 'study_subject_id', :dir => 'desc'
			assert_response :success
			assert_template 'index'
			assert_select ".arrow", :count => 0
			assert_equal 0, assigns(:birth_data).length
		end
	
		test "should get index with order study_subject_id and dir desc "<<
				"with #{cu} login and birth datum" do
			FactoryBot.create(:birth_datum)
			login_as send(cu)
			get :index, :order => 'study_subject_id', :dir => 'desc'
			assert_response :success
			assert_template 'index'
			assert_select ".arrow", :count => 1
			assert_equal 1, assigns(:birth_data).length
		end
	
		test "should get index with order study_subject_id and dir asc "<<
				"with #{cu} login and birth datum" do
			FactoryBot.create(:birth_datum)
			login_as send(cu)
			get :index, :order => 'study_subject_id', :dir => 'asc'
			assert_response :success
			assert_template 'index'
			assert_select ".arrow", :count => 1
			assert_equal 1, assigns(:birth_data).length
		end
	
	end

end
