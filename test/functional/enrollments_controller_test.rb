require 'test_helper'

class EnrollmentsControllerTest < ActionController::TestCase

	#	no subject_id
	assert_no_route(:get,:index)
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Enrollment',
		:actions => [:show,:edit,:update],	#	only the shallow ones
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_enrollment
	}
	def factory_attributes(options={})
		Factory.attributes_for(:enrollment,
			{:project_id => Factory(:project).id}.merge(options))
	end

	assert_access_with_login({ 
		:actions => [:show],
		:logins  => site_readers })
	assert_no_access_with_login({ 
		:actions => [:show],
		:logins  => non_site_readers })

	assert_access_with_login({ 
		:actions => [:edit,:update],
		:logins  => site_editors })
	assert_no_access_with_login({ 
		:actions => [:edit,:update],
		:logins  => non_site_editors })

	assert_no_access_without_login

	site_editors.each do |cu|

		test "should NOT get enrollments with invalid subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :index, :subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to subjects_path
		end

		test "should get new enrollment with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			get :new, :subject_id => subject.id
			assert assigns(:subject)
			assert assigns(:projects)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new enrollment with invalid subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :new, :subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to subjects_path
		end

		test "should create enrollment with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			assert_difference("Subject.find(#{subject.id}).enrollments.count",1) {
			assert_difference('Enrollment.count',1) {
				post :create, :subject_id => subject.id,
					:enrollment => factory_attributes
			} }
			assert assigns(:subject)
			assert_redirected_to edit_enrollment_path(assigns(:enrollment))
		end

		test "should NOT create enrollment with invalid subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :subject_id => 0, :enrollment => {
					:project_id => Factory(:project).id }
			end
			assert_not_nil flash[:error]
			assert_redirected_to subjects_path
		end

		test "should NOT create enrollment with #{cu} login " <<
			"when create fails" do
			subject = Factory(:subject)
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :subject_id => subject.id, :enrollment => {
					:project_id => Factory(:project).id }
			end
			assert assigns(:subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create enrollment with #{cu} login and " <<
			"invalid enrollment" do
			e = create_enrollment
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :subject_id => e.subject.id,
					:enrollment => factory_attributes(
						:project_id => e.project_id)
			end
			assert assigns(:enrollment).errors.on(:project_id)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end


		test "should edit enrollment with #{cu} login" do
			enrollment = create_enrollment
			login_as send(cu)
			get :edit, :subject_id => enrollment.subject.id, :id => enrollment.id
			assert assigns(:enrollment)
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit enrollment with invalid id and #{cu} login" do
			enrollment = create_enrollment
			login_as send(cu)
			get :edit, :subject_id => enrollment.subject.id, :id => 0
			assert_redirected_to subjects_path
		end

		test "should update enrollment with #{cu} login" do
			enrollment = create_enrollment(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			assert_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :subject_id => enrollment.subject.id, 
					:id => enrollment.id,
					:enrollment => factory_attributes
			}
			assert assigns(:enrollment)
			assert_redirected_to enrollment_path(enrollment)
		end

		test "should NOT update enrollment with invalid id and #{cu} login" do
			enrollment = create_enrollment(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :subject_id => enrollment.subject.id, 
					:id => 0,
					:enrollment => factory_attributes
			}
			assert_redirected_to subjects_path
		end

		test "should NOT update enrollment with #{cu} login " <<
			"when update fails" do
			enrollment = create_enrollment(:updated_at => Chronic.parse('yesterday'))
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :id => enrollment.id,
					:enrollment => factory_attributes
			}
			assert assigns(:enrollment)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT update enrollment with #{cu} login " <<
			"and invalid enrollment" do
			enrollment = create_enrollment(:updated_at => Chronic.parse('yesterday'))
	#		e = create_enrollment(:study_subject_id => enrollment.subject.id)
	#	TODO (confirm ok)
			e = create_enrollment(:subject => enrollment.subject)
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :id => enrollment.id,
					:enrollment => factory_attributes(
						:project_id => e.project_id)
			}
			assert assigns(:enrollment).errors.on(:project_id)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

	end

	non_site_editors.each do |cu|

	end

######################################################################

	site_readers.each do |cu|

		test "should get enrollments with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			get :index, :subject_id => subject.id
			assert assigns(:subject)
			assert_response :success
			assert_template 'index'
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get enrollments with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			get :index, :subject_id => subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new enrollment with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			get :new, :subject_id => subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create enrollment with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			post :create, :subject_id => subject.id,
				:enrollment => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get enrollments without login" do
		subject = Factory(:subject)
		get :index, :subject_id => subject.id
		assert_redirected_to_login
	end

	test "should NOT get new enrollment without login" do
		subject = Factory(:subject)
		get :new, :subject_id => subject.id
		assert_redirected_to_login
	end

	test "should NOT create enrollment without login" do
		subject = Factory(:subject)
		post :create, :subject_id => subject.id,
			:enrollment => factory_attributes
		assert_redirected_to_login
	end

end
