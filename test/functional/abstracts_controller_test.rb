require 'test_helper'

class AbstractsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Abstract',
		:actions => [:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_abstract
	}
	assert_access_with_login({ 
		:logins => site_editors })
	assert_no_access_with_login({ 
		:logins => non_site_editors })
	assert_no_access_without_login

	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	def factory_attributes(options={})
		FactoryBot.attributes_for(:abstract,{
		}.merge(options))
	end

	site_editors.each do |cu|

		test "should get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:abstracts)
			assert_equal 0, assigns(:abstracts).length
		end

		test "should get index with abstracts and #{cu} login" do
			FactoryBot.create(:abstract)
			FactoryBot.create(:abstract)
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:abstracts)
			assert_equal 2, assigns(:abstracts).length
		end

		test "should get merged index with #{cu} login" do
			FactoryBot.create(:abstract)
			FactoryBot.create(:abstract,:merged_by_uid => '1234')
			login_as send(cu)
			get :merged
			assert_response :success
			assert_template 'index'
			assert assigns(:abstracts)
			assert_equal 1, assigns(:abstracts).length
		end

		test "should get to_merge index with #{cu} login" do
			FactoryBot.create(:abstract)
			a1 = FactoryBot.create(:abstract)
			FactoryBot.create(:abstract,:study_subject_id => a1.study_subject_id)
			login_as send(cu)
			get :to_merge
			assert_response :success
			assert_template 'index'
			assert assigns(:abstracts)
			assert_equal 2, assigns(:abstracts).length
		end


	##################################################
	#		Begin Find Order Tests (only on fields in table)

		test "should find abstracts and order by id with #{cu} login" do
			abstracts = 3.times.collect{|i| FactoryBot.create(:abstract) }
			login_as send(cu)
			get :index, :order => :id
			assert_response :success
			assert_equal abstracts, assigns(:abstracts)
		end

		test "should find abstracts and order by id asc with #{cu} login" do
			abstracts = 3.times.collect{|i| FactoryBot.create(:abstract) }
			login_as send(cu)
			get :index, :order => :id, :dir => :asc
			assert_response :success
			assert_equal abstracts, assigns(:abstracts)
		end

		test "should find abstracts and order by id desc with #{cu} login" do
			abstracts = 3.times.collect{|i| FactoryBot.create(:abstract) }
			login_as send(cu)
			get :index, :order => :id, :dir => :desc
			assert_response :success
			assert_equal abstracts, assigns(:abstracts).reverse
		end

	#		End Find Order Tests
	##################################################

	end

	non_site_editors.each do |cu|

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_redirected_to root_path
		end

	end

	#	not logged in ..

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

end
