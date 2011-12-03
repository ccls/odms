require 'test_helper'

class ConsentsControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get, :show)
#	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	#	no route
	assert_no_route(:get,:new,:study_subject_id => 0)
	assert_no_route(:post,:create,:study_subject_id => 0)

	site_editors.each do |cu|

		test "should update and create subject_languages if given with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 0 ){
				@study_subject = Factory(:study_subject)
			}
			login_as send(cu)
			put :update, :study_subject_id => @study_subject.id, :study_subject => { :subject_languages_attributes => {
				:some_random_id => { :language_id => Language.first.id }
			} }
#	assert subject has languages
pending	#	TODO
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should update and destroy subject_languages if given with #{cu} login" do
			assert_difference( 'SubjectLanguage.count', 1 ){
				@study_subject = Factory(:study_subject, :subject_languages_attributes => {
					:some_random_id => { :language_id => Language.first.id }
			} ) }
			subject_language = @study_subject.subject_languages.first
			login_as send(cu)
#			assert_difference( 'SubjectLanguage.count', -1 ){
				put :update, :study_subject_id => @study_subject.id, :study_subject => { :subject_languages_attributes => {
					:some_random_id => { :id => subject_language.id, :_destroy => 1 } } }
#			}
#	assert subject has no more languages
pending	#	TODO
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should NOT update consent if study_subject update fails with #{cu} login" do
pending	#	TODO
		end

		test "should NOT update consent if patient update fails with #{cu} login" do
pending	#	TODO
		end


		test "should create ccls enrollment on edit if none exists with #{cu} login" do
			study_subject = Factory(:study_subject)
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil ccls_enrollment	#	auto-created
			ccls_enrollment.destroy
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_nil ccls_enrollment
			assert_equal 0, study_subject.enrollments.length
			login_as send(cu)
			assert_difference('Enrollment.count',1) {
				get :edit, :study_subject_id => study_subject.id
			}
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil ccls_enrollment	#	auto-created
		end

		test "should NOT create ccls enrollment on edit if one exists with #{cu} login" do
			study_subject = Factory(:study_subject)
			ccls_enrollment = study_subject.enrollments.find_by_project_id(Project['ccls'].id)
			assert_not_nil ccls_enrollment	#	auto-created
			login_as send(cu)
			assert_difference('Enrollment.count',0) {
				get :edit, :study_subject_id => study_subject.id
			}
		end

#
#	Gotta handle cases and non-cases.
#	Gotta deal with patient fields.
#	Gotta deal with subject languages.
#	These multiple models will need to be wrapped in a transaction.
#

		test "should edit consent with #{cu} login" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_not_nil assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'edit'
		end

		test "should have eligibility criteria on case edit consent with #{cu} login" do
			study_subject = Factory(:case_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'edit'
			assert_select "div.eligibility_criteria", :count => 1
		end

		test "should NOT have eligibility criteria on control edit consent with #{cu} login" do
			study_subject = Factory(:control_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'edit'
			assert_select "div.eligibility_criteria", :count => 0
		end

		test "should NOT have eligibility criteria on mother edit consent with #{cu} login" do
			study_subject = Factory(:mother_study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_response :success
			assert_template 'edit'
			assert_select "div.eligibility_criteria", :count => 0
		end

		test "should NOT edit consent with invalid study_subject_id #{cu} login" do
			login_as send(cu)
			get :edit, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update consent with #{cu} login" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id,
				:enrollment => Factory.attributes_for(:enrollment)
			assert_nil     flash[:error]
			assert_not_nil flash[:notice]
			assert_redirected_to study_subject_consent_path(assigns(:study_subject))
		end

		test "should NOT update consent with invalid study_subject_id and #{cu} login" do
			login_as send(cu)
			put :update, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update consent with #{cu} login and invalid enrollment" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			Enrollment.any_instance.stubs(:valid?).returns(false)
			put :update, :study_subject_id => study_subject.id,
				:enrollment => Factory.attributes_for(:enrollment)
			assert_nil     flash[:notice]
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update consent with #{cu} login and save fails" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
			put :update, :study_subject_id => study_subject.id,
				:enrollment => Factory.attributes_for(:enrollment)
			assert_nil     flash[:notice]
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT edit consent with #{cu} login" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update consent with #{cu} login" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			put :update, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

		test "should get consents with #{cu} login" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_not_nil assigns(:enrollment)
			assert_response :success
			assert_template 'show'
		end

		test "should NOT get consents with invalid study_subject_id " <<
			"and #{cu} login" do
			login_as send(cu)
			get :show, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT get consents for mother with #{cu} login" do
			login_as send(cu)
			mother = Factory(:mother_study_subject)
			get :show, :study_subject_id => mother.id
			assert_nil flash[:error]
			assert_match /data is only collected for child subjects. Please go to the record for the subject's child for details/, 
				@response.body
			assert_response :success
			assert_template 'show_mother'
			assert_nil assigns(:enrollment)
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get consents with #{cu} login" do
#			study_subject = Factory(:enrollment).study_subject
			study_subject = Factory(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get consents without login" do
#		study_subject = Factory(:enrollment).study_subject
		study_subject = Factory(:study_subject)
		get :show, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get edit consent without login" do
#		study_subject = Factory(:enrollment).study_subject
		study_subject = Factory(:study_subject)
		get :edit, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT update consent without login" do
#		study_subject = Factory(:enrollment).study_subject
		study_subject = Factory(:study_subject)
		put :update, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

end
