require 'test_helper'

class SubjectsControllerTest < ActionController::TestCase

	setup :create_home_exposure_with_subject

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Subject',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:before => :create_home_exposure_subjects,
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_subject
	}
	def factory_attributes(options={})
		Factory.attributes_for(:subject,{
			:subject_type_id => Factory(:subject_type).id,
			:race_id => Factory(:race).id}.merge(options))
	end

	assert_access_with_login({ 
		:logins => [:superuser,:admin,:editor,:interviewer,:reader] })
	assert_no_access_with_login({ 
		:logins => [:active_user] })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http

	assert_no_access_with_login(
		:attributes_for_create => nil,
		:method_for_create => nil,
		:actions => nil,
		:suffix => " and invalid id",
		:redirect => :subjects_path,
		:login => :superuser,
		:update => { :id => 0 },
		:destroy => { :id => 0 },
		:edit => { :id => 0 },
		:show => { :id => 0 }
	)

%w( superuser admin editor interviewer reader ).each do |cu|

#		test "should get index with subjects with #{cu} login" do
#	#puts Subject.all.length
#	#puts Subject.all.inspect
#			assert_equal 1, Subject.for_hx.length		#	from :create_home_exposure_with_subject
#			survey = Survey.find_by_access_code("home_exposure_survey")
#			rs1 = rs2 = rs3 = rs4 = rs5 = nil
#			assert_difference('Subject.count',3) {
#			assert_difference('ResponseSet.count',5) {
#				rs1 = fill_out_survey(:survey => survey)
#				rs2 = fill_out_survey(:survey => survey, :subject => rs1.subject)
#				rs2.to_her
#				rs3 = fill_out_survey(:survey => survey)
#				rs4 = fill_out_survey(:survey => survey, :subject => rs3.subject)
#				rs5 = fill_out_survey(:survey => survey)
#			} }
#	#puts "About to fail"
#	#puts Subject.for_hx.inspect
#	#Subject.for_hx.each do |s|
#	#puts s.enrollments.inspect
#	#end
#			assert_equal 1, Subject.for_hx.length	#	the survey doesn't make'em "for_hx"
#			assert_difference('Project.count',1) {
#				create_project	#Factory(:project)	#	test search code in view
#			}
#			#	There should now be 3 + 1 subjects in different states.
#			login_as send(cu)
#			get :index
#			assert_equal 1, assigns(:subjects).length
#			assert_response :success
#			assert_template 'index'
#		end

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
		subject = create_subject(
			:pii_attributes => Factory.attributes_for(:pii))
		login_as send(cu)
		get :show, :id => subject
		assert_response :success
		assert_template 'show'
	end

	test "should have do_not_contact if it is true "<<
			"with #{cu} login" do
		subject = create_subject(:do_not_contact => true)
		login_as send(cu)
		get :show, :id => subject
		assert_response :success
		assert_template 'show'
		assert_select "#do_not_contact", :count => 1
		assert_select "#do_not_contact", 1
	end

	test "should NOT have do_not_contact if it is false "<<
			"with #{cu} login" do
		subject = create_subject(:do_not_contact => false)
		login_as send(cu)
		get :show, :id => subject
		assert_response :success
		assert_template 'show'
		assert_select "#do_not_contact", :count => 0
		assert_select "#do_not_contact", 0
		assert_select "#do_not_contact", false
	end

	test "should have hospital link if subject is case "<<
			"with #{cu} login" do
		subject = create_subject(:subject_type => SubjectType['Case'])
		assert subject.reload.is_case?
		login_as send(cu)
		get :show, :id => subject
		assert_response :success
		assert_template 'show'
		assert_select "#submenu", :count => 1 do
			assert_select "a", :count => 5
			assert_select "a", 5
			assert_select "a", :count => 1, :text => 'hospital'
#	apparently 1 doesn't work if :text exists
#			assert_select "a", 1, :text => 'hospital'
		end
		#	<div id='submenu'>
		#	<a href="/subjects/2" class="current">general</a>
		#	<a href="/subjects/2/patient">hospital</a>
		#	<a href="/subjects/2/contacts">address/contact</a>
		#	<a href="/subjects/2/enrollments">eligibility/enrollments</a>
		#	<a href="/subjects/2/events">events</a>
		#	</div><!-- submenu -->
	end

#		test "should NOT have hospital link if subject is not case "<<
#				"with #{cu} login" do
#			subject = create_subject
#			assert !subject.reload.is_case?
#			login_as send(cu)
#			get :show, :id => subject
#			assert_response :success
#			assert_template 'show'
#			assert_select "#submenu", :count => 1 do
#				assert_select "a", :count => 4
#				assert_select "a", 4
#				assert_select "a", :count => 0, :text => 'hospital'
#	#	apparently 0 and false don't work if :text exists
#	#			assert_select "a", 0, :text => 'hospital'
#	#			assert_select "a", false, :text => 'hospital'
#			end
#		end

	test "should download csv with #{cu} login" do
		login_as send(cu)
		get :index, :commit => 'download'
		assert_response :success
		assert_not_nil @response.headers['Content-disposition'].match(/attachment;.*csv/)
	end

	test "should update with #{cu} login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		assert_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id, 
				:subject => Factory.attributes_for(:subject)
		} } } }
		assert_redirected_to subject_path(assigns(:subject))
	end

	test "should NOT create with #{cu} login" <<
		" with invalid subject" do
		login_as send(cu)
		Subject.any_instance.stubs(:valid?).returns(false)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
			post :create, :subject => {}
		} } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	test "should NOT create with #{cu} login" <<
		" when save fails" do
		login_as send(cu)
		Subject.any_instance.stubs(:create_or_update).returns(false)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
			post :create, :subject => {}
		} } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end


	test "should NOT create without subject_type_id with #{cu} login" do
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
			post :create, 
				:subject => Factory.attributes_for(:subject,
					:subject_type_id => nil )
		} } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	test "should NOT create without race_id with #{cu} login" do
		subject = create_subject
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
			post :create, 
				:subject => Factory.attributes_for(:subject,
					:race_id => nil )
		} } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	test "should NOT create without valid subject_type_id with #{cu} login" do
		subject = create_subject
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
			post :create, 
				:subject => Factory.attributes_for(:subject,
					:subject_type_id => 0 )
		} } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end

	test "should NOT create without valid race_id with #{cu} login" do
		subject = create_subject
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
			post :create, 
				:subject => Factory.attributes_for(:subject,
					:race_id => 0 )
		} } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'new'
	end


	test "should NOT update with #{cu} login" <<
		" and invalid" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		Subject.any_instance.stubs(:valid?).returns(false)
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id,
				:subject => {}
		} } } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT update with #{cu} login" <<
		" and save fails" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		Subject.any_instance.stubs(:create_or_update).returns(false)
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id,
				:subject => {}
		} } } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT update without subject_type_id with #{cu} login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id,
				:subject => { :subject_type_id => nil }
		} } } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT update without race_id with #{cu} login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id,
				:subject => { :race_id => nil }
		} } } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT update without valid subject_type_id with #{cu} login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id,
				:subject => { :subject_type_id => 0 }
		} } } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT update without valid race_id with #{cu} login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id,
				:subject => { :race_id => 0 }
		} } } }
		assert_not_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end



end

%w( active_user ).each do |cu|

	test "should NOT download csv with #{cu} login" do
		login_as send(cu)
		get :index, :commit => 'download'
		assert_redirected_to root_path
	end

	test "should NOT update with #{cu} login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id, 
				:subject => Factory.attributes_for(:subject)
		} } } }
		assert_not_nil flash[:error]
		assert_redirected_to root_path
	end

end

	test "should NOT download csv without login" do
		get :index, :commit => 'download'
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		subject = create_subject(:updated_at => Chronic.parse('yesterday'))
		assert_difference('Subject.count',0){
		assert_difference('SubjectType.count',0){
		assert_difference('Race.count',0){
		deny_changes("Subject.find(#{subject.id}).updated_at") {
			put :update, :id => subject.id, 
				:subject => Factory.attributes_for(:subject)
		} } } }
		assert_redirected_to_login
	end


protected

	def create_home_exposure_subjects
#puts "Running create_home_exposure_subjects"
		p = Project.find_or_create_by_code('HomeExposures')
assert_difference('Subject.count',3) {
assert_difference('Enrollment.count',3) {
		3.times do
			s  = create_subject
			Factory(:enrollment, :subject => s, :project => p )
			s
		end
} }
	end

end
