require 'test_helper'

class StudySubjectsControllerTest < ActionController::TestCase

#	setup :create_home_exposure_with_study_subject
	setup :create_study_subject

	ASSERT_ACCESS_OPTIONS = {
		:model => 'StudySubject',
#		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:actions => [:show,:index],
#		:before => :create_home_exposure_study_subjects,
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_study_subject
	}
	def factory_attributes(options={})
		Factory.attributes_for(:study_subject,{
			:subject_type_id => Factory(:subject_type).id,
			:race_ids => [Race.random.id]}.merge(options))
	end

	assert_access_with_login({ 
		:actions => [:edit,:update],
		:logins  => site_editors })

	assert_no_access_with_login({ 
		:actions => [:edit,:update],
		:logins  => non_site_editors })

	assert_access_with_login({ 
		:actions => [:show,:index],
		:logins  => site_readers })

	assert_no_access_with_login({ 
		:actions => [:show,:index],
		:logins  => non_site_readers })

	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

	assert_no_access_with_login(
		:actions => nil,
		:suffix => " and invalid id",
		:redirect => :study_subjects_path,
		:login => site_readers,
		:method_for_create => nil,
		:show => { :id => 0 }
	)

#	assert_no_access_with_login(
#		:attributes_for_create => nil,
#		:method_for_create => nil,
#		:actions => nil,
#		:suffix => " and invalid id",
#		:redirect => :study_subjects_path,
#		:login => :superuser,
#		:update => { :id => 0 },
#		:destroy => { :id => 0 },
#		:edit => { :id => 0 },
#		:show => { :id => 0 }
#	)

	site_readers.each do |cu|

		test "should get index with order and dir desc with #{cu} login" do
			login_as send(cu)
			get :index, :order => 'last_name', :dir => 'desc'
			assert_response :success
			assert_template 'index'
			assert_select "span.arrow", :count => 1
			assert_select "span.arrow", 1
		end
	
		test "should get index with order and dir asc with #{cu} login" do
			login_as send(cu)
			get :index, :order => 'last_name', :dir => 'asc'
			assert_response :success
			assert_template 'index'
			assert_select "span.arrow", :count => 1
			assert_select "span.arrow", 1
		end
	
		test "should get show with pii with #{cu} login" do
			study_subject = create_study_subject(
				:pii_attributes => Factory.attributes_for(:pii))
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
		end
	
		test "should have do_not_contact if it is true "<<
				"with #{cu} login" do
			study_subject = create_study_subject(:do_not_contact => true)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
			assert_select "#do_not_contact", :count => 1
			assert_select "#do_not_contact", 1
		end
	
		test "should NOT have do_not_contact if it is false "<<
				"with #{cu} login" do
			study_subject = create_study_subject(:do_not_contact => false)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
			assert_select "#do_not_contact", :count => 0
			assert_select "#do_not_contact", 0
			assert_select "#do_not_contact", false
		end
	
		test "should have hospital link if study_subject is case "<<
				"with #{cu} login" do
			study_subject = create_study_subject(:subject_type => SubjectType['Case'])
			assert study_subject.reload.is_case?
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
#			assert_select "#submenu", :count => 1 do
			assert_select "#sidemenu", :count => 1 do

#				assert_select "span", :count => 1
#				assert_select "a", :count => 1

#	currently in dev so they are spans
#				assert_select "a", :count => 5
#				assert_select "a", 5
#				assert_select "a", :count => 1, :text => 'hospital'

	#	apparently 1 doesn't work if :text exists
	#			assert_select "a", 1, :text => 'hospital'
			end
			#	<div id='sidemenu'>
			#	<a href="/study_subjects/2" class="current">general</a>
			#	<a href="/study_subjects/2/patient">hospital</a>
			#	<a href="/study_subjects/2/contacts">address/contact</a>
			#	<a href="/study_subjects/2/enrollments">eligibility/enrollments</a>
			#	<a href="/study_subjects/2/events">events</a>
			#	</div><!-- sidemenu -->
		end
	
		test "should download csv with #{cu} login" do
			login_as send(cu)
			get :index, :commit => 'download'
			assert_response :success
			assert_not_nil @response.headers['Content-disposition'].match(/attachment;.*csv/)
		end

		test "should get study_subjects dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
		end
	
	end

	non_site_readers.each do |cu|

		test "should NOT download csv with #{cu} login" do
			login_as send(cu)
			get :index, :commit => 'download'
			assert_redirected_to root_path
		end

		test "should NOT get study_subjects dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
	end

#######################################################################

	site_editors.each do |cu|

		test "should update with #{cu} login" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('SubjectType.count',0){
			assert_difference('Race.count',0){
			assert_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id, 
					:study_subject => Factory.attributes_for(:study_subject)
			} } } }
			assert_redirected_to study_subject_path(assigns(:study_subject))
		end
	
#		test "should NOT create with #{cu} login" <<
#			" with invalid study_subject" do
#			login_as send(cu)
#			StudySubject.any_instance.stubs(:valid?).returns(false)
#			assert_difference('StudySubject.count',0){
#			assert_difference('SubjectType.count',0){
#			assert_difference('Race.count',0){
#				post :create, :study_subject => {}
#			} } }
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'new'
#		end
#	
#		test "should NOT create with #{cu} login" <<
#			" when save fails" do
#			login_as send(cu)
#			StudySubject.any_instance.stubs(:create_or_update).returns(false)
#			assert_difference('StudySubject.count',0){
#			assert_difference('SubjectType.count',0){
#			assert_difference('Race.count',0){
#				post :create, :study_subject => {}
#			} } }
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'new'
#		end
#	
#	
#		test "should NOT create without subject_type_id with #{cu} login" do
#			login_as send(cu)
#			assert_difference('StudySubject.count',0){
#			assert_difference('SubjectType.count',0){
#			assert_difference('Race.count',0){
#				post :create, 
#					:study_subject => Factory.attributes_for(:study_subject,
#						:subject_type_id => nil )
#			} } }
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'new'
#		end
#	
#		test "should NOT create without race_id with #{cu} login" do
#			study_subject = create_study_subject
#			login_as send(cu)
#pending
##			assert_difference('StudySubject.count',0){
##			assert_difference('SubjectType.count',0){
##			assert_difference('Race.count',0){
##				post :create, 
##					:study_subject => Factory.attributes_for(:study_subject,
##						:race_id => nil )
##			} } }
##			assert_not_nil flash[:error]
##			assert_response :success
##			assert_template 'new'
#		end
#	
#		test "should NOT create without valid subject_type_id with #{cu} login" do
#			study_subject = create_study_subject
#			login_as send(cu)
#			assert_difference('StudySubject.count',0){
#			assert_difference('SubjectType.count',0){
#			assert_difference('Race.count',0){
#				post :create, 
#					:study_subject => Factory.attributes_for(:study_subject,
#						:subject_type_id => 0 )
#			} } }
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'new'
#		end
#	
#		test "should NOT create without valid race_id with #{cu} login" do
#			study_subject = create_study_subject
#			login_as send(cu)
#pending
##			assert_difference('StudySubject.count',0){
##			assert_difference('SubjectType.count',0){
##			assert_difference('Race.count',0){
##				post :create, 
##					:study_subject => Factory.attributes_for(:study_subject,
##						:race_id => 0 )
##			} } }
##			assert_not_nil flash[:error]
##			assert_response :success
##			assert_template 'new'
#		end
	
	
		test "should NOT update with #{cu} login" <<
			" and invalid" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			StudySubject.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('SubjectType.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id,
					:study_subject => {}
			} } } }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end
	
		test "should NOT update with #{cu} login" <<
			" and save fails" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('SubjectType.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id,
					:study_subject => {}
			} } } }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end
	
		test "should NOT update without subject_type_id with #{cu} login" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('SubjectType.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id,
					:study_subject => { :subject_type_id => nil }
			} } } }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end
	
		test "should NOT update without race_id with #{cu} login" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
pending
#			assert_difference('StudySubject.count',0){
#			assert_difference('SubjectType.count',0){
#			assert_difference('Race.count',0){
#			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
#				put :update, :id => study_subject.id,
#					:study_subject => { :race_id => nil }
#			} } } }
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'edit'
		end
	
		test "should NOT update without valid subject_type_id with #{cu} login" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('SubjectType.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id,
					:study_subject => { :subject_type_id => 0 }
			} } } }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end
	
		test "should NOT update without valid race_id with #{cu} login" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
pending
#			assert_difference('StudySubject.count',0){
#			assert_difference('SubjectType.count',0){
#			assert_difference('Race.count',0){
#			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
#				put :update, :id => study_subject.id,
#					:study_subject => { :race_ids => [0] }
#			} } } }
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'edit'
		end
	
	end

	non_site_editors.each do |cu|

		test "should NOT update with #{cu} login" do
			study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('SubjectType.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id, 
					:study_subject => Factory.attributes_for(:study_subject)
			} } } }
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#######################################################################

	non_site_editors.each do |cu|

	end

#######################################################################

	test "should NOT download csv without login" do
		get :index, :commit => 'download'
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		study_subject = create_study_subject(:updated_at => Chronic.parse('yesterday'))
		assert_difference('StudySubject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
			put :update, :id => study_subject.id, 
				:study_subject => Factory.attributes_for(:study_subject)
		} } } }
		assert_redirected_to_login
	end

protected

	def create_home_exposure_study_subjects
		p = Project.find_or_create_by_code('HomeExposures')
		assert_difference('StudySubject.count',3) {
		assert_difference('Enrollment.count',3) {
			3.times do
				s  = create_study_subject
				Factory(:enrollment, :study_subject => s, :project => p )
				s
			end
		} }
	end

end
