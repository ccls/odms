require 'test_helper'

class PatientsControllerTest < ActionController::TestCase

	#	no route
	assert_no_route(:get,:index)

	#	no study_subject_id (has_one so no id needed)
	assert_no_route(:get,:show)	
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

#	Not shallow routes so can't use
#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Patient',
#		:actions => [:edit,:update],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_patient
#	}
	def factory_attributes(options={})
		Factory.attributes_for(:patient,options)
	end

#	assert_access_with_login({ 
#		:logins => [:superuser,:admin,:editor] })
#	assert_no_access_with_login({ 
#		:logins => [:interviewer,:reader,:active_user] })
#	assert_no_access_without_login

	site_editors.each do |cu|

		test "should show patient with #{cu} login" do
			patient = create_patient_with_study_subject
			login_as send(cu)
			get :show, :study_subject_id => patient.study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'show'
		end

		test "should NOT show patient with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :show, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show patient for patientless study_subject " <<
				"and #{cu} login" do
			study_subject = create_case_study_subject
			assert_nil study_subject.patient
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_equal study_subject, assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should NOT get new patient with #{cu} login " <<
				"for study_subject with patient" do
			patient = create_patient_with_study_subject
			login_as send(cu)
			get :new, :study_subject_id => patient.study_subject.id
			assert assigns(:study_subject)
			assert_redirected_to study_subject_patient_path(assigns(:study_subject))
		end

		test "should get new patient with #{cu} login " <<
				"for study_subject without patient" do
			study_subject = create_case_study_subject
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert assigns(:patient)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new patient with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new patient with #{cu} login" do
			study_subject = create_case_study_subject
			login_as send(cu)
			assert_difference('Patient.count',1) do
				post :create, :study_subject_id => study_subject.id,
					:patient => factory_attributes
			end
			assert assigns(:study_subject)
			assert_redirected_to study_subject_patient_path(study_subject)
		end

		test "should NOT create new patient with #{cu} login " <<
				"for non-case study_subject" do
			study_subject = create_study_subject
			login_as send(cu)
			assert_difference('Patient.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:patient => factory_attributes
			end
			assert_not_nil flash[:error]
			assert assigns(:study_subject)
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should NOT create new patient with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			assert_difference('Patient.count',0) do
				post :create, :study_subject_id => 0, 
					:patient => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create new patient with #{cu} " <<
				"login when create fails" do
			study_subject = create_case_study_subject
			Patient.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Patient.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:patient => factory_attributes
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new patient with #{cu} " <<
				"login and invalid patient" do
			study_subject = create_case_study_subject
			Patient.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('Patient.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:patient => factory_attributes
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should edit patient with #{cu} login" do
			patient = create_patient_with_study_subject
			login_as send(cu)
			get :edit, :study_subject_id => patient.study_subject.id
			assert assigns(:patient)
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit patient with invalid " <<
				"study_subject_id and #{cu} login" do
			patient = create_patient
			login_as send(cu)
			get :edit, :study_subject_id => 0
			assert_redirected_to study_subjects_path
		end

		test "should update patient with #{cu} login" do
			patient = create_patient_with_study_subject
			login_as send(cu)
			put :update, :study_subject_id => patient.study_subject.id,
				:patient => factory_attributes
			assert assigns(:patient)
			assert_redirected_to study_subject_patient_path(patient.study_subject)
		end

		test "should NOT update patient with invalid " <<
				"study_subject_id and #{cu} login" do
			patient = create_patient(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			deny_changes("Patient.find(#{patient.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:patient => factory_attributes
			}
			assert_redirected_to study_subjects_path
		end

		test "should NOT update patient with #{cu} " <<
				"login when update fails" do
			patient = create_patient_with_study_subject(:updated_at => Chronic.parse('yesterday'))
			Patient.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Patient.find(#{patient.id}).updated_at") {
				put :update, :study_subject_id => patient.study_subject.id,
					:patient => factory_attributes
			}
			assert assigns(:patient)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT update patient with #{cu} " <<
				"login and invalid patient" do
			patient = create_patient_with_study_subject(:updated_at => Chronic.parse('yesterday'))
			Patient.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			deny_changes("Patient.find(#{patient.id}).updated_at") {
				put :update, :study_subject_id => patient.study_subject.id,
					:patient => factory_attributes
			}
			assert assigns(:patient)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should destroy patient with #{cu} login" do
			login_as send(cu)
			study_subject = create_patient_with_study_subject.study_subject
			assert_not_nil study_subject.patient
			assert_difference('Patient.count', -1) do
				delete :destroy, :study_subject_id => study_subject.id
			end
			assert_nil study_subject.reload.patient
			assert_redirected_to study_subject_path(study_subject)
		end

	end


	non_site_editors.each do |cu|

		test "should NOT show patient with #{cu} login" do
			study_subject = create_case_study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new patient with #{cu} login" do
			study_subject = create_case_study_subject
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new patient with #{cu} login" do
			study_subject = create_case_study_subject
			login_as send(cu)
			post :create, :study_subject_id => study_subject.id,
				:patient => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT destroy patient with #{cu} login" do
			login_as send(cu)
			study_subject = create_patient_with_study_subject.study_subject
			assert_not_nil study_subject.patient
			assert_difference('Patient.count', 0) do
				delete :destroy, :study_subject_id => study_subject.id
			end
			assert_not_nil study_subject.patient
			assert_redirected_to root_path
		end

	end

	test "should NOT show patient without login" do
		study_subject = create_case_study_subject
		get :show, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new patient without login" do
		study_subject = create_case_study_subject
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new patient without login" do
		study_subject = create_case_study_subject
		post :create, :study_subject_id => study_subject.id,
			:patient => factory_attributes
		assert_redirected_to_login
	end

	test "should NOT destroy patient without login" do
		study_subject = create_patient_with_study_subject.study_subject
		assert_not_nil study_subject.patient
		assert_difference('Patient.count', 0) do
			delete :destroy, :study_subject_id => study_subject.id
		end
		assert_not_nil study_subject.patient
		assert_redirected_to_login
	end

protected

	#	TODO clean this up
	def create_patient_with_study_subject(options={})
		patient = create_patient({
			:study_subject => Factory(:case_study_subject)
		}.merge(options))
		assert_not_nil patient.id
		assert_not_nil patient.study_subject
		patient.reload
	end

end
