require 'test_helper'

class EventsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'OperationalEvent',
		:actions => [:edit,:update,:destroy],
		:attributes_for_create => :factory_attributes,	#	needed for update
		:method_for_create => :create_operational_event_with_enrollment
	}
	def create_operational_event_with_enrollment(options={})
		Factory(:operational_event,{
			:enrollment => Factory(:enrollment)}.merge(options) )
	end
	def factory_attributes(options={})
		Factory.attributes_for(:operational_event,{
			:operational_event_type_id => Factory(:operational_event_type).id
		}.merge(options))
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
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	site_editors.each do |cu|




#	TODO add update tests that ensure event doesn't change subjects
#			when changing enrollment_id




		test "should get new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should create new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('study_subject.operational_events.count',1){
			assert_difference('OperationalEvent.count',1){
			assert_difference('Enrollment.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes(
						:enrollment_id => study_subject.enrollments.find_by_project_id(
							Project['ccls'].id).id)
			} } }
			assert_not_nil flash[:notice]
			assert_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

		test "should NOT create new event for study_subject with #{cu} login" <<
				" and study_subject_id and enrollment.study_subject_id don't match" do
			login_as send(cu)
#
#	we don't want to allow using one subject to assign an event to an
#	enrollment of another subject.	This could be dangerous.
#	So assign to the route study_subject?
#	What if doesn't have an enrollment in that project?
#
			route_study_subject = Factory(:study_subject)
			enrollment_study_subject = Factory(:study_subject)

			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => route_study_subject.id,
					:operational_event => factory_attributes(
						:enrollment_id => enrollment_study_subject.enrollments.find_by_project_id(
							Project['ccls'].id).id)
			}
			assert_nil flash[:notice]
			assert_not_nil flash[:error]
			assert_match /Mismatch/, flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create new event for study_subject with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => 0,
					:operational_event => factory_attributes(
						:enrollment_id => study_subject.enrollments.find_by_project_id(
							Project['ccls'].id).id)
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path	#study_subject_events_path(study_subject)
		end

		test "should NOT create new event for study_subject with #{cu} login" <<
				" and invalid operational event" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes(
						:enrollment_id => study_subject.enrollments.find_by_project_id(
							Project['ccls'].id).id)
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create new event for study_subject with #{cu} login" <<
				" and operational event save fails" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes(
						:enrollment_id => study_subject.enrollments.find_by_project_id(
							Project['ccls'].id).id)
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

		test "should NOT create new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes(
						:enrollment_id => study_subject.enrollments.find_by_project_id(
							Project['ccls'].id).id)
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

	end

	site_readers.each do |cu|

		test "should get events with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get events with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get events with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get events without login" do
		study_subject = Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new event for study_subject without login" do
		study_subject = Factory(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new event for study_subject without login" do
		study_subject = Factory(:study_subject)
		assert_difference('OperationalEvent.count',0){
			post :create, :study_subject_id => study_subject.id,
				:operational_event => factory_attributes(
					:enrollment_id => study_subject.enrollments.find_by_project_id(
						Project['ccls'].id).id)
		}
		assert_redirected_to_login
	end

end
