require 'test_helper'

class EventsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'OperationalEvent',
		:actions => [:edit,:update,:destroy],
		:attributes_for_create => :factory_attributes,	#	needed for update
		:method_for_create => :create_operational_event_with_subject
	}
	def create_operational_event_with_subject(options={})
		Factory(:operational_event,{
			:study_subject => Factory(:study_subject)}.merge(options) )
	end
	def factory_attributes(options={})
		Factory.attributes_for(:operational_event,{
			:operational_event_type_id => Factory(:operational_event_type).id,
			:project_id => Project['ccls'].id
		}.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_access_with_login({    :logins => site_readers, 
		:actions => [:show] })
	assert_no_access_with_login({ :logins => non_site_readers, 
		:actions => [:show] })
	assert_no_access_without_login

	#	no study_subject_id
	assert_no_route(:get,:index)
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	site_administrators.each do |cu|

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
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes
			} }
			assert_not_nil flash[:notice]
			assert_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

		test "should NOT create new event for study_subject with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => 0,
					:operational_event => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create new event for study_subject with #{cu} login" <<
				" and invalid operational event" do
			login_as send(cu)
			study_subject = Factory(:study_subject)
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes
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
					:operational_event => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

	end

	non_site_administrators.each do |cu|

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
					:operational_event => factory_attributes
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
				:operational_event => factory_attributes
		}
		assert_redirected_to_login
	end

end
