require 'test_helper'

class StudySubject::EnrollmentsControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get,:index)
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

#	NO DESTROY


#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Enrollment',
#		:actions => [:show,:edit,:update],	#	only the shallow ones
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_enrollment
#	}
#
#	assert_access_with_login({ 
#		:actions => [:show],
#		:logins  => site_readers })
#	assert_no_access_with_login({ 
#		:actions => [:show],
#		:logins  => non_site_readers })
#
#	assert_access_with_login({ 
#		:actions => [:edit,:update],
#		:logins  => site_editors })
#	assert_no_access_with_login({ 
#		:actions => [:edit,:update],
#		:logins  => non_site_editors })
#
#	assert_no_access_without_login

	def factory_attributes(options={})
		Factory.attributes_for(:enrollment,
			{:project_id => Factory(:project).id}.merge(options))
	end

	site_editors.each do |cu|

		test "should get new enrollment with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert assigns(:projects)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new enrollment with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create enrollment with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			assert_difference("StudySubject.find(#{study_subject.id}).enrollments.count",1) {
			assert_difference('Enrollment.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:enrollment => factory_attributes
			} }
			assert assigns(:study_subject)
			assert_redirected_to edit_study_subject_enrollment_path(study_subject, assigns(:enrollment))
		end

		test "should NOT create enrollment with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :study_subject_id => 0, :enrollment => {
					:project_id => Factory(:project).id }
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create enrollment with #{cu} login " <<
			"when create fails" do
			study_subject = Factory(:study_subject)
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :study_subject_id => study_subject.id, :enrollment => {
					:project_id => Factory(:project).id }
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create enrollment with #{cu} login and " <<
			"invalid enrollment" do
			e = Factory(:enrollment)
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :study_subject_id => e.study_subject.id,
					:enrollment => factory_attributes(
						:project_id => e.project_id)
			end
			assert assigns(:enrollment).errors.include?(:project_id)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should create operational event if consented on update with #{cu} login" do
			enrollment = Factory(:enrollment)
			study_subject = enrollment.study_subject
			login_as send(cu)
			assert_difference("study_subject.operational_events.count",1) {
				put :update, :study_subject_id => study_subject.id, :id => enrollment.id,
					:enrollment => { :consented => YNDK[:yes],
						:consented_on => Date.current }
			}
			assert assigns(:enrollment)
			oe = study_subject.operational_events.where(
				:project_id => enrollment.project_id).first
			assert_equal OperationalEventType['subjectConsents'],
				oe.operational_event_type
			assert_redirected_to study_subject_enrollment_path(study_subject,enrollment)
		end

		test "should create operational event if declines on update with #{cu} login" do
			enrollment = Factory(:enrollment)
			study_subject = enrollment.study_subject
			login_as send(cu)
			assert_difference("study_subject.operational_events.count",1) {
				put :update, :study_subject_id => study_subject.id, :id => enrollment.id,
					:enrollment => { :consented => YNDK[:no],
						:refusal_reason_id => Factory(:refusal_reason).id,
						:consented_on => Date.current }
			}
			assert assigns(:enrollment)
			oe = study_subject.operational_events.where(
				:project_id => enrollment.project_id).first
			assert_equal OperationalEventType['subjectDeclines'],
				oe.operational_event_type
#			assert_equal OperationalEventType['subjectDeclines'],
#				assigns(:enrollment).operational_events.first.operational_event_type
			assert_redirected_to study_subject_enrollment_path(study_subject,enrollment)
		end


		test "should edit with #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :edit, :study_subject_id => enrollment.study_subject_id,
				:id => enrollment.id
			assert_response :success
			assert_template 'edit'
			assert_nil flash[:error]
		end

		test "should NOT edit with mismatched study_subject_id #{cu} login" do
			enrollment = Factory(:enrollment)
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => enrollment.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid study_subject_id #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :edit, :study_subject_id => 0,
				:id => enrollment.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid id #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :edit, :study_subject_id => enrollment.study_subject_id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update with #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => enrollment.study_subject_id,
					:id => enrollment.id, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_enrollment_path(enrollment.study_subject_id,enrollment.id)
		end

		test "should NOT update with save failure and #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => enrollment.study_subject_id,
					:id => enrollment.id, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with invalid and #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			Enrollment.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => enrollment.study_subject_id,
					:id => enrollment.id, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with mismatched study_subject_id #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			study_subject = Factory(:study_subject)
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => enrollment.id, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid study_subject_id #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:id => enrollment.id, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid id #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => enrollment.study_subject_id,
					:id => 0, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new enrollment with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create enrollment with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			post :create, :study_subject_id => study_subject.id,
				:enrollment => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			get :edit, :study_subject_id => enrollment.study_subject_id,
				:id => enrollment.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
				put :update, :study_subject_id => enrollment.study_subject_id,
					:id => enrollment.id, :enrollment => factory_attributes(
						:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

######################################################################

	site_readers.each do |cu|

		test "should get enrollments with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get enrollments with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT get enrollments for mother with #{cu} login" do
			login_as send(cu)
			mother = Factory(:mother_study_subject)
			get :index, :study_subject_id => mother.id
			assert_nil flash[:error]
			assert_match /data is only collected for child subjects. Please go to the record for the subject's child for details/, 
				@response.body
			assert_response :success
			assert_template 'index_mother'
		end

		test "should show with #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :show, :study_subject_id => enrollment.study_subject_id,
				:id => enrollment.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'show'
		end

		test "should NOT show with mismatched study_subject_id #{cu} login" do
			enrollment = Factory(:enrollment)
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id,
				:id => enrollment.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid study_subject_id #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :show, :study_subject_id => 0,
				:id => enrollment.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid id #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :show, :study_subject_id => enrollment.study_subject_id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get enrollments with #{cu} login" do
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT show with #{cu} login" do
			enrollment = Factory(:enrollment)
			login_as send(cu)
			get :show, :study_subject_id => enrollment.study_subject_id,
				:id => enrollment.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	#	not logged in ..

	test "should NOT get enrollments without login" do
		study_subject = Factory(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new enrollment without login" do
		study_subject = Factory(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create enrollment without login" do
		study_subject = Factory(:study_subject)
		post :create, :study_subject_id => study_subject.id,
			:enrollment => factory_attributes
		assert_redirected_to_login
	end

	test "should NOT show without login" do
		enrollment = Factory(:enrollment)
		get :show, :study_subject_id => enrollment.study_subject_id,
			:id => enrollment.id
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		enrollment = Factory(:enrollment)
		get :edit, :study_subject_id => enrollment.study_subject_id,
			:id => enrollment.id
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		enrollment = Factory(:enrollment, :updated_at => ( Time.now - 1.day ) )
		deny_changes("Enrollment.find(#{enrollment.id}).updated_at") {
			put :update, :study_subject_id => enrollment.study_subject_id,
				:id => enrollment.id, :enrollment => factory_attributes(
					:notes => 'trigger update')
		}
		assert_redirected_to_login
	end

end
