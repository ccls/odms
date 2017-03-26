require 'test_helper'

class StudySubject::EventsControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::EventsController

	#	no study_subject_id
	assert_no_route(:get,:index)
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'OperationalEvent',
#		:actions => [:edit,:update,:destroy],
#		:attributes_for_create => :factory_attributes,	#	needed for update
#		:method_for_create => :create_operational_event_with_subject
#	}
#
#	assert_access_with_login({    :logins => site_administrators })
#	assert_no_access_with_login({ :logins => non_site_administrators })
#	assert_access_with_login({    :logins => site_readers, 
#		:actions => [:show] })
#	assert_no_access_with_login({ :logins => non_site_readers, 
#		:actions => [:show] })
#	assert_no_access_without_login


	def create_operational_event_with_subject(options={})
		FactoryGirl.create(:operational_event,{
			:study_subject => FactoryGirl.create(:study_subject)}.merge(options) )
	end
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:operational_event,{
			:operational_event_type_id => FactoryGirl.create(:operational_event_type).id,
			:project_id => Project['ccls'].id
		}.merge(options))
	end

	site_administrators.each do |cu|

		test "should get new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should create new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
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
			study_subject = FactoryGirl.create(:study_subject)
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
			study_subject = FactoryGirl.create(:study_subject)
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
			study_subject = FactoryGirl.create(:study_subject)
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should edit with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => operational_event.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit with mismatched study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => operational_event.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :edit, :study_subject_id => 0,
				:id => operational_event.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ),
				:study_subject => study_subject )
			login_as send(cu)
			assert_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => operational_event.id, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_event_path(study_subject, operational_event)
		end

		test "should NOT update with save failure and #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ),
				:study_subject => study_subject )
			login_as send(cu)
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => operational_event.id, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with invalid and #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ),
				:study_subject => study_subject )
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => operational_event.id, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with mismatched study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => operational_event.id, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ),
				:study_subject => study_subject )
			login_as send(cu)
			deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:id => operational_event.id, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ),
				:study_subject => study_subject )
			login_as send(cu)
			deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => 0, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should destroy with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			assert_difference('OperationalEvent.count',-1){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => operational_event.id
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

		test "should NOT destroy with mismatched study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event)
			login_as send(cu)
			assert_difference('OperationalEvent.count',0){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => operational_event.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			assert_difference('OperationalEvent.count',0){
				delete :destroy, :study_subject_id => 0,
					:id => operational_event.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			assert_difference('OperationalEvent.count',0){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => 0
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT get new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

		test "should NOT create new event for study_subject with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			assert_difference('OperationalEvent.count',0){
				post :create, :study_subject_id => study_subject.id,
					:operational_event => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subject_events_path(study_subject)
		end

		test "should NOT edit with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => operational_event.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, 
				:updated_at => ( Time.now - 1.day ),
				:study_subject => study_subject )
			login_as send(cu)
			deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => operational_event.id, :operational_event => {
						:notes => 'trigger update' }
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT destroy with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			assert_difference('OperationalEvent.count',0){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => operational_event.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

		test "should get events with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
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

		test "should order events by occurred_at asc default with #{cu} login" do
			oes = create_occurred_at_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by occurred_at with #{cu} login" do
			oes = create_occurred_at_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, :order => :occurred_at
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by occurred_at asc with #{cu} login" do
			oes = create_occurred_at_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :occurred_at, :dir => :asc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by occurred_at desc with #{cu} login" do
			oes = create_occurred_at_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :occurred_at, :dir => :desc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]].reverse
		end




		test "should order events by project with #{cu} login" do
			oes = create_project_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, :order => :project
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by project asc with #{cu} login" do
			oes = create_project_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :project, :dir => :asc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by project desc with #{cu} login" do
			oes = create_project_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :project, :dir => :desc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]].reverse
		end

		test "should order events by type with #{cu} login" do
			oes = create_category_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, :order => :type
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by type asc with #{cu} login" do
			oes = create_category_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :type, :dir => :asc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by type desc with #{cu} login" do
			oes = create_category_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :type, :dir => :desc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]].reverse
		end

		test "should order events by description with #{cu} login" do
			oes = create_description_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, :order => :description
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by description asc with #{cu} login" do
			oes = create_description_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :description, :dir => :asc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]]
		end

		test "should order events by description desc with #{cu} login" do
			oes = create_description_operational_events
			study_subject = oes[0].study_subject
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id, 
				:order => :description, :dir => :desc
			assert_equal assigns(:events), [oes[1],oes[0],oes[2]].reverse
		end

		test "should show with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id,
				:id => operational_event.id
			assert_response :success
			assert_template 'show'
			assert_nil flash[:error]
		end

		test "should NOT show with mismatched study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id,
				:id => operational_event.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid study_subject_id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :show, :study_subject_id => 0,
				:id => operational_event.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid id #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get events with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT show with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id,
				:id => operational_event.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	#	not logged in ..

	test "should NOT get events without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new event for study_subject without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new event for study_subject without login" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_difference('OperationalEvent.count',0){
			post :create, :study_subject_id => study_subject.id,
				:operational_event => factory_attributes
		}
		assert_redirected_to_login
	end

	test "should NOT show without login" do
		study_subject = FactoryGirl.create(:study_subject)
		operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
		get :show, :study_subject_id => study_subject.id,
			:id => operational_event.id
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		study_subject = FactoryGirl.create(:study_subject)
		operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
		get :edit, :study_subject_id => study_subject.id,
			:id => operational_event.id
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		study_subject = FactoryGirl.create(:study_subject)
		operational_event = FactoryGirl.create(:operational_event, 
			:updated_at => ( Time.now - 1.day ),
			:study_subject => study_subject )
		deny_changes("OperationalEvent.find(#{operational_event.id}).updated_at") {
			put :update, :study_subject_id => study_subject.id,
				:id => operational_event.id, :operational_event => {
					:notes => 'trigger update' }
		}
		assert_redirected_to_login
	end

	test "should NOT destroy without login" do
		study_subject = FactoryGirl.create(:study_subject)
		operational_event = FactoryGirl.create(:operational_event, :study_subject => study_subject )
		assert_difference('OperationalEvent.count',0){
			delete :destroy, :study_subject_id => study_subject.id,
				:id => operational_event.id
		}
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :operational_event,
		[ :occurred_at, :project_id, :operational_event_type_id, 
			:description, :notes ],
		[:study_subject_id])

protected

	def create_operational_events(*args)
		study_subject = FactoryGirl.create(:study_subject)
		study_subject.operational_events.destroy_all
		args.collect{|options| create_operational_event(
			options.merge(:study_subject => study_subject)) }
	end

	def create_occurred_at_operational_events
		today = DateTime.current
		create_operational_events(
			{ :occurred_at => ( today - 1.month ) },
			{ :occurred_at => ( today - 1.year ) },
			{ :occurred_at => ( today - 1.week ) }
		)
	end

	def create_description_operational_events
		create_operational_events(
			{ :description => 'M' },
			{ :description => 'A' },
			{ :description => 'Z' }
		)
	end

	def create_category_operational_events
		create_operational_events(
			{ :operational_event_type => FactoryGirl.create(
				:operational_event_type,:event_category => 'MMMM') },
			{ :operational_event_type => FactoryGirl.create(
				:operational_event_type,:event_category => 'AAAA') },
			{ :operational_event_type => FactoryGirl.create(
				:operational_event_type,:event_category => 'ZZZZ') }
		)
	end

	def create_project_operational_events
		create_operational_events(
			{ :project => FactoryGirl.create(
				:project,:key => 'MMMM') },
			{ :project => FactoryGirl.create(
				:project,:key => 'AAAA') },
			{ :project => FactoryGirl.create(
				:project,:key => 'ZZZZ') }
		)
	end

end
