require 'test_helper'

class StudySubject::PatientsControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::PatientsController

	#	no route
	assert_no_route(:get,:index)

	#	no study_subject_id (has_one so no id needed)
	assert_no_route(:get,:show)	
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

	def factory_attributes(options={})
		FactoryBot.attributes_for(:patient,options)
	end

	#	All nested routes, so common class-level assertions won't work

	site_editors.each do |cu|

		test "should show patient with #{cu} login" do
			patient = FactoryBot.create(:patient)
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

		test "should NOT show patient for patientless case study_subject " <<
				"and #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			assert_nil study_subject.patient
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_equal study_subject, assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should NOT show patient for control subject with #{cu} login" do
			study_subject = FactoryBot.create(:control_study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_match /Hospital data is valid for case subjects only/,
				@response.body
			assert_template 'not_case'
		end

		test "should NOT show patient for mother subject with #{cu} login" do
			study_subject = FactoryBot.create(:mother_study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_match /Hospital data is valid for case subjects only/,
				@response.body
			assert_template 'not_case'
		end

		test "should NOT get new patient with #{cu} login " <<
				"for study_subject with patient" do
			patient = FactoryBot.create(:patient)
			login_as send(cu)
			get :new, :study_subject_id => patient.study_subject.id
			assert assigns(:study_subject)
			assert_redirected_to study_subject_patient_path(assigns(:study_subject))
		end

		test "should get new patient with #{cu} login " <<
				"for study_subject without patient" do
			study_subject = FactoryBot.create(:case_study_subject)
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
			study_subject = FactoryBot.create(:case_study_subject)
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
			study_subject = FactoryBot.create(:study_subject)
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
			study_subject = FactoryBot.create(:case_study_subject)
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
			study_subject = FactoryBot.create(:case_study_subject)
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
			patient = FactoryBot.create(:patient)
			login_as send(cu)
			get :edit, :study_subject_id => patient.study_subject.id
			assert assigns(:patient)
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit patient for case subject without patient and #{cu} login" do
			#	doesn't actually test case/control unless new/create
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_nil assigns(:patient)
			assert_not_nil flash[:error]
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should NOT edit patient for control subject without patient and #{cu} login" do
			#	doesn't actually test case/control unless new/create
			study_subject = FactoryBot.create(:control_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_nil assigns(:patient)
			assert_not_nil flash[:error]
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should NOT edit patient with invalid " <<
				"study_subject_id and #{cu} login" do
			patient = FactoryBot.create(:patient)
			login_as send(cu)
			get :edit, :study_subject_id => 0
			assert_redirected_to study_subjects_path
		end

		test "should update patient with #{cu} login" do
			patient = FactoryBot.create(:patient)
			login_as send(cu)
			put :update, :study_subject_id => patient.study_subject.id,
				:patient => factory_attributes
			assert assigns(:patient)
			assert_redirected_to study_subject_patient_path(patient.study_subject)
		end

		test "should NOT update patient for case subject without patient and #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id,
				:patient => factory_attributes
			assert_nil assigns(:patient)
			assert_not_nil flash[:error]
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should NOT update patient for control subject without patient and #{cu} login" do
			#	doesn't actually test case/control unless new/create
			study_subject = FactoryBot.create(:control_study_subject)
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id,
				:patient => factory_attributes
			assert_nil assigns(:patient)
			assert_not_nil flash[:error]
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should NOT update patient with invalid " <<
				"study_subject_id and #{cu} login" do
			patient = FactoryBot.create(:patient,:updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Patient.find(#{patient.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:patient => factory_attributes
			}
			assert_redirected_to study_subjects_path
		end

		test "should NOT update patient with #{cu} " <<
				"login when update fails" do
			patient = FactoryBot.create(:patient,:updated_at => ( Time.now - 1.day ) )
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
			patient = FactoryBot.create(:patient,:updated_at => ( Time.now - 1.day ) )
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
			study_subject = FactoryBot.create(:patient).study_subject.reload
			assert_not_nil study_subject.patient
			assert_difference('Patient.count', -1) do
				delete :destroy, :study_subject_id => study_subject.id
			end
			assert_nil study_subject.reload.patient
			assert_redirected_to study_subject_path(study_subject)
		end

		test "should destroy patient for control subject without patient and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryBot.create(:control_study_subject)
			assert_nil study_subject.patient
			assert_difference('Patient.count', 0) do
				delete :destroy, :study_subject_id => study_subject.id
			end
#	This is kinda a stupid, but should never really happen.
#	Try to destroy something that doesn't exist so redirect to
#		someplace to create one.
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

		test "should destroy patient for case subject without patient and #{cu} login" do
			login_as send(cu)
			study_subject = FactoryBot.create(:case_study_subject)
			assert_nil study_subject.patient
			assert_difference('Patient.count', 0) do
				delete :destroy, :study_subject_id => study_subject.id
			end
#	This is kinda a stupid, but should never really happen.
#	Try to destroy something that doesn't exist so redirect to
#		someplace to create one.
			assert_redirected_to new_study_subject_patient_path(study_subject)
		end

	end


	non_site_editors.each do |cu|

		test "should NOT show patient with #{cu} login" do
			study_subject = FactoryBot.create(:patient).study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get new patient with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new patient with #{cu} login" do
			study_subject = FactoryBot.create(:case_study_subject)
			login_as send(cu)
			post :create, :study_subject_id => study_subject.id,
				:patient => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT destroy patient with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryBot.create(:patient).study_subject.reload
			assert_not_nil study_subject.patient
			assert_difference('Patient.count', 0) do
				delete :destroy, :study_subject_id => study_subject.id
			end
			assert_not_nil study_subject.patient
			assert_redirected_to root_path
		end

	end

	test "should NOT show patient without login" do
		study_subject = FactoryBot.create(:patient).study_subject
		get :show, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new patient without login" do
		study_subject = FactoryBot.create(:case_study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new patient without login" do
		study_subject = FactoryBot.create(:case_study_subject)
		post :create, :study_subject_id => study_subject.id,
			:patient => factory_attributes
		assert_redirected_to_login
	end

	test "should NOT destroy patient without login" do
		study_subject = FactoryBot.create(:patient).study_subject.reload
		assert_not_nil study_subject.patient
		assert_difference('Patient.count', 0) do
			delete :destroy, :study_subject_id => study_subject.id
		end
		assert_not_nil study_subject.patient
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :patient,
		[ :admit_date, :diagnosis_date, :diagnosis, :other_diagnosis, 
			:organization_id, :hospital_no ],
		[:study_subject_id])

end
