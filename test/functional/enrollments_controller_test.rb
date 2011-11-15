require 'test_helper'

class EnrollmentsControllerTest < ActionController::TestCase

	#	no study_subject_id
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

		test "should NOT get enrollments with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

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
			assert_redirected_to edit_enrollment_path(assigns(:enrollment))
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
			e = create_enrollment
			login_as send(cu)
			assert_difference('Enrollment.count',0) do
				post :create, :study_subject_id => e.study_subject.id,
					:enrollment => factory_attributes(
						:project_id => e.project_id)
			end
			assert assigns(:enrollment).errors.on(:project_id)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should create operational event if consented on update with #{cu} login" do
			enrollment = create_enrollment
			login_as send(cu)
			assert_changes("Enrollment.find(#{enrollment.id}).operational_events.count",1) {
				put :update, :id => enrollment.id,
					:enrollment => { :consented => YNDK[:yes],
						:consented_on => Date.today }
			}
			assert assigns(:enrollment)
			assert_redirected_to enrollment_path(enrollment)
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

		test "should NOT get consents for mother with #{cu} login" do
			login_as send(cu)
#			study_subject = mother = nil
#			assert_difference('Enrollment.count',2) {
#			assert_difference('StudySubject.count',2) {
#				study_subject = Factory(:identifier).reload.study_subject
#				assert_not_nil study_subject.identifier
#				#	subject currently needs identifier to use create_mother
#				mother = study_subject.create_mother
#			} }
#			assert_not_nil mother
#			ccls_enrollment = mother.enrollments.find_by_project_id(Project['ccls'].id)
#			assert_not_nil ccls_enrollment
			mother = Factory(:mother_study_subject)
			get :index, :study_subject_id => mother.id
			assert_not_nil flash[:error]
			assert_match /This is a mother subject. .*data is only collected for child subjects. Please go to the record for the subject's child for details/, flash[:error]
			assert_response :success
			assert_template 'index_mother'
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

	end

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

end
