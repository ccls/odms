require 'test_helper'

class StudySubjectsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'StudySubject',
		:actions => [:show,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_study_subject
	}
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:study_subject,{
			:updated_at => ( Time.now + 1.day ),
			:race_ids => [Race['white'].id]}.merge(options))
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

	assert_no_access_with_login(
		:actions => nil,
		:suffix => " and invalid id",
		:redirect => :study_subjects_path,
		:login => site_readers,
		:method_for_create => nil,
		:show => { :id => 0 }
	)


	site_administrators.each do |cu|

		#	test to ensure no NESTED FORMS!!!
		#	sadly, html validation doesn't seem to do this
		test "should get index with subjects and NO NESTED FORMS and #{cu} login" do
			study_subjects = 3.times.collect{|i| FactoryGirl.create(:study_subject) }
			login_as send(cu)
			get :index
			assert_response :success
			assert_equal 3, assigns(:study_subjects).length
			assert_select "form form", { :count => 0 }, "Nested forms are invalid and dangerous"
		end

	end

	site_readers.each do |cu|

		test "should get index with order and dir desc with #{cu} login" do
			FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :order => 'last_name', :dir => 'desc'
			assert_response :success
			assert_template 'index'
			assert_select ".arrow", :count => 1
			assert_select ".arrow", 1
		end
	
		test "should get index with order and dir asc with #{cu} login" do
			FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :order => 'last_name', :dir => 'asc'
			assert_response :success
			assert_template 'index'
			assert_select ".arrow", :count => 1
			assert_select ".arrow", 1
		end
	
		test "should have do_not_contact if it is true "<<
				"with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject, :do_not_contact => true)
			login_as send(cu)
			get :show, :id => study_subject.id
			assert_response :success
			assert_template 'show'
			assert_select "#do_not_contact", :count => 1
			assert_select "#do_not_contact", 1
		end
	
		test "should NOT have do_not_contact if it is false "<<
				"with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject, :do_not_contact => false)
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
			study_subject = FactoryGirl.create(:case_study_subject)
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
	
#		test "should download csv with #{cu} login" do
#			login_as send(cu)
##	This works, but the link for this is a button on a form.
##	So I really need to deal with this in the controller
##			get :index, :commit => 'download', :format => 'csv'
#			get :index, :commit => 'download'
#			assert_response :success
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
#		end
#
#		test "should download csv matching content with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject,
#					:first_name => 'Sam', :last_name => 'Adams')
#			assert_not_nil study_subject.childid
#			assert_not_nil study_subject.last_name
#			assert_not_nil study_subject.first_name
#			assert_not_nil study_subject.dob
#
#			login_as send(cu)
#			get :index, :format => 'csv'
#			assert_response :success
#			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
#			assert_template 'index'
#			assert assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#			assert_equal 1, assigns(:study_subjects).length
#
#			require 'csv'
#			f = CSV.parse(@response.body)
#			assert_equal 2, f.length	#	2 rows, 1 header and 1 data
#			assert_equal f[0], ["childid", "studyid", "last_name", "first_name", "dob"]
#			assert_equal 5, f[0].length
#
#			assert_equal f[1][0], study_subject.childid.to_s
##			assert_equal f[1][1], study_subject.studyid 	#	blank
#			assert_equal f[1][2], study_subject.last_name
#			assert_equal f[1][3], study_subject.first_name
#			assert_equal f[1][4], study_subject.dob.to_s(:db)	#	YYYY-MM-DD
#
##	don't know why bc_requests have a blank line and this doesn't
##assert f[2].blank?
#		end

		test "should get study_subjects dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_response :success
		end
	
		test "should get study_subjects followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_response :success
		end
	
		test "should get study_subjects reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_response :success
		end
	
		test "should get next study_subject with no next #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			get :next, :id => study_subject.id
			assert_redirected_to study_subject
		end
	
		test "should get next study_subject with next #{cu} login" do
			login_as send(cu)
			this_study_subject = FactoryGirl.create(:study_subject)
			next_study_subject = FactoryGirl.create(:study_subject)
			get :next, :id => this_study_subject.id
			assert_redirected_to next_study_subject
		end
	
		test "should get prev study_subject with no prev #{cu} login" do
			login_as send(cu)
			study_subject = FactoryGirl.create(:study_subject)
			get :prev, :id => study_subject.id
			assert_redirected_to study_subject
		end
	
		test "should get prev study_subject with prev #{cu} login" do
			login_as send(cu)
			prev_study_subject = FactoryGirl.create(:study_subject)
			this_study_subject = FactoryGirl.create(:study_subject)
			get :prev, :id => this_study_subject.id
			assert_redirected_to prev_study_subject
		end
	
		test "should get first study_subject with last #{cu} login" do
			login_as send(cu)
			first_study_subject = FactoryGirl.create(:study_subject)
			FactoryGirl.create(:study_subject)
			this_study_subject = FactoryGirl.create(:study_subject)
			get :first	#	now irrelevant ... , :id => this_study_subject.id
			assert_redirected_to first_study_subject
		end
	
		test "should get last study_subject with first #{cu} login" do
			login_as send(cu)
			this_study_subject = FactoryGirl.create(:study_subject)
			FactoryGirl.create(:study_subject)
			last_study_subject = FactoryGirl.create(:study_subject)
			get :last	#	now irrelevant ... , :id => this_study_subject.id
			assert_redirected_to last_study_subject
		end

		test "should redirect to study_subject by icf_master_id with #{cu} login" do
			login_as send(cu)
			subject = FactoryGirl.create(:study_subject, :icf_master_id => "1234FIND")
			get :by, :icf_master_id => '1234FIND'
			assert_redirected_to subject
		end

		test "should flash warn if no study_subject with icf_master_id with #{cu} login" do
			login_as send(cu)
			get :by, :icf_master_id => '1234FIND'
			assert_not_nil flash[:warn]
			assert_redirected_to root_path
		end
	
	end

	non_site_readers.each do |cu|

#		test "should NOT download csv with #{cu} login" do
#			login_as send(cu)
#			get :index, :commit => 'download'
#			assert_redirected_to root_path
#		end

		test "should NOT get study_subjects dashboard with #{cu} login" do
			login_as send(cu)
			get :dashboard
			assert_redirected_to root_path
		end
	
		test "should NOT get study_subjects find with #{cu} login" do
			login_as send(cu)
			get :index
			assert_redirected_to root_path
		end
	
		test "should NOT get study_subjects followup with #{cu} login" do
			login_as send(cu)
			get :followup
			assert_redirected_to root_path
		end
	
		test "should NOT get study_subjects reports with #{cu} login" do
			login_as send(cu)
			get :reports
			assert_redirected_to root_path
		end
	
	end

#######################################################################

	site_editors.each do |cu|

		test "should update with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('Race.count',0){
			assert_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id, 
					:study_subject => FactoryGirl.attributes_for(:study_subject,
						:sex => 'DK' )	#	sex is M or F in the Factory so DK will make it change
			} } }
			assert_redirected_to study_subject_path(assigns(:study_subject))
		end

		test "should NOT update with #{cu} login" <<
			" and invalid" do
			study_subject = FactoryGirl.create(:study_subject, 
				:updated_at => ( Time.now - 1.day ) )
			StudySubject.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id,
					:study_subject => {}
			} } }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end
	
		test "should NOT update with #{cu} login" <<
			" and save fails" do
			study_subject = FactoryGirl.create(:study_subject, :updated_at => ( Time.now - 1.day ) )
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id,
					:study_subject => {}
			} } }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end
	
	end

	non_site_editors.each do |cu|

		test "should NOT update with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_difference('StudySubject.count',0){
			assert_difference('Race.count',0){
			deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
				put :update, :id => study_subject.id, 
					:study_subject => FactoryGirl.attributes_for(:study_subject)
			} } }
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#######################################################################

	non_site_editors.each do |cu|

	end

#######################################################################

	test "should NOT get study_subjects dashboard without login" do
		get :dashboard
		assert_redirected_to_login
	end
	
	test "should NOT get study_subjects find without login" do
		get :index
		assert_redirected_to_login
	end
	
	test "should NOT get study_subjects followup without login" do
		get :followup
		assert_redirected_to_login
	end
	
	test "should NOT get study_subjects reports without login" do
		get :reports
		assert_redirected_to_login
	end
	
#	test "should NOT download csv without login" do
#		get :index, :commit => 'download'
#		assert_redirected_to_login
#	end

	test "should NOT update without login" do
		study_subject = FactoryGirl.create(:study_subject, :updated_at => ( Time.now - 1.day ) )
		assert_difference('StudySubject.count',0){
		assert_difference('Race.count',0){
		deny_changes("StudySubject.find(#{study_subject.id}).updated_at") {
			put :update, :id => study_subject.id, 
				:study_subject => FactoryGirl.attributes_for(:study_subject)
		} } }
		assert_redirected_to_login
	end

#protected
#
#	def create_home_exposure_study_subjects
#		p = Project.find_or_create_by(key: 'HomeExposures')
#		assert_difference('StudySubject.count',3) {
#		assert_difference('Enrollment.count',3) {
#			3.times do
#				s  = create_study_subject
#				FactoryGirl.create(:enrollment, :study_subject => s, :project => p )
#				s
#			end
#		} }
#	end

end
