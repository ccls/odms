require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
#	assert_no_route(:get,:new,:study_subject_id => 0)
#	assert_no_route(:post,:create,:study_subject_id => 0)
	
	site_readers.each do |cu|

		test "should get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_response :success
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
		end
	
		test "should get find with #{cu} login" do
			login_as send(cu)
			get :find
			assert_response :success
		end
	
		test "should get followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_response :success
		end
	
		test "should get reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_response :success
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT get index with #{cu} login and valid study_subject_id" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
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
	
end

__END__


require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Sample',
		:actions => [:edit,:update,:show,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample
	}
	def factory_attributes(options={})
		# No attributes from Factory yet
		Factory.attributes_for(:sample,{
			:updated_at => Time.now,
#			:sample_type_id => SampleType.not_roots.first,	
			:sample_type_id => Factory(:sample_type).id,
			:unit_id => Factory(:unit).id }.merge(options))
	end

	assert_access_with_login({ 
		:logins => site_editors })
	assert_no_access_with_login({
		:logins => non_site_editors })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

#	TODO duplicate?
	assert_no_access_with_login(
		:attributes_for_create => nil,
		:method_for_create => nil,
		:actions => nil,
		:suffix => " and invalid id",
		:login => :superuser,
		:redirect => :study_subjects_path,
		:edit => { :id => 0 },
		:update => { :id => 0 },
		:show => { :id => 0 },
		:destroy => { :id => 0 }
	) 

	site_editors.each do |cu|

		test "should get sample index with #{cu} login" do
			login_as send(cu)
			study_subject = create_study_subject	#Factory(:study_subject)
			get :index, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'index'
		end

		test "should get new sample with #{cu} login" do
			login_as send(cu)
			study_subject = create_study_subject	#Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = create_study_subject	#Factory(:study_subject)
			assert_difference('Sample.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_nil flash[:error]
			assert_redirected_to sample_path(assigns(:sample))
		end

		test "should NOT create with #{cu} login " <<
			"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = create_study_subject	#Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

#	TODO duplicate?
		test "should NOT update with #{cu} login " <<
			"and invalid sample" do
			login_as send(cu)
			sample = create_sample(:updated_at => ( Time.now - 1.day ) )
			Sample.any_instance.stubs(:valid?).returns(false)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :id => sample.id,
					:sample => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT create with #{cu} login " <<
			"and save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = create_study_subject	#Factory(:study_subject)
			assert_difference('Sample.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

#	TODO duplicate?
		test "should NOT update with #{cu} login " <<
			"and save failure" do
			login_as send(cu)
			sample = create_sample(:updated_at => ( Time.now - 1.day ) )
			Sample.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :id => sample.id,
					:sample => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get sample index with #{cu} login" do
			login_as send(cu)
			study_subject = create_study_subject	#Factory(:study_subject)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new sample with #{cu} login" do
			login_as send(cu)
			study_subject = create_study_subject	#Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = create_study_subject	#Factory(:study_subject)
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get sample index without login" do
		study_subject = create_study_subject	#Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new sample without login" do
		study_subject = create_study_subject	#Factory(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = create_study_subject	#Factory(:study_subject)
		post :create, :study_subject_id => study_subject.id,
			:sample => factory_attributes
		assert_redirected_to_login
	end

end
