require 'test_helper'

class CasesControllerTest < ActionController::TestCase

	site_editors.each do |cu|

		test "should get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil assigns(:study_subjects)
			assert assigns(:study_subjects).empty?
			assert_response :success
			assert_template 'index'
		end

		test "should get index with subjects #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index in csv with subjects #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :format => :csv
			assert_response :success
			assert_template :index
			#	will this be set automatically??? hmm, let's see ... NOPE
			#	must explicitly set this.  Is that necessary? Doesn't seem to be.
			assert_not_nil @response.headers['Content-Disposition']
				.match(/attachment; filename=newcases_.*csv/)
			assert  assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert_equal 1, assigns(:study_subjects).length
			assert_equal subject, assigns(:study_subjects).first
		end

#		test "should get index with blank assigned_for_interview_at and #{cu} login" do
#			login_as send(cu)
#			subject = subject_for_assigned_for_interview_at
#			get :index, :assigned_for_interview_at => ''
#			assert_not_nil assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#			assert assigns(:study_subjects).include?(subject)
#			assert_response :success
#			assert_template 'index'
#		end
#
#		test "should get index with assigned_for_interview_at and #{cu} login" do
#			login_as send(cu)
#			subject = subject_for_assigned_for_interview_at
#			get :index, :assigned_for_interview_at => Date.current
#			assert_not_nil assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#			assert assigns(:study_subjects).include?(subject)
#			assert_response :success
#			assert_template 'index'
#		end
#
#		test "should get index with invalid assigned_for_interview_at and #{cu} login" do
#			login_as send(cu)
#			subject = subject_for_assigned_for_interview_at
#			get :index, :assigned_for_interview_at => "FUNKAY MUNGKAY"
#			assert_not_nil assigns(:study_subjects)
#			assert !assigns(:study_subjects).empty?
#			assert assigns(:study_subjects).include?(subject)
#			assert_response :success
#			assert_template 'index'
#		end

		test "should get index with exclusive ids" <<
				" and #{cu} login" do
			login_as send(cu)
			missed_subject = FactoryGirl.create(:study_subject)
			subject = subject_for_assigned_for_interview_at
			get :index, :ids => [missed_subject.id]
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert !assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with inclusive ids" <<
				" and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :ids => [subject.id]
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert  assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with invalid ids" <<
				" and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :ids => [99999]
			assert_not_nil assigns(:study_subjects)
			assert  assigns(:study_subjects).empty?
			assert !assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end




		test "should update assigned_for_interview_at with ids and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			put :assign_selected_for_interview, :ids => [subject.id]
			assert_not_nil subject.enrollments.where(
				:project_id => Project[:ccls].id).first.assigned_for_interview_at
			assert_not_nil flash[:notice]
			assert_redirected_to cases_path(:ids => [subject.id],:format => :csv)
		end

		test "should NOT update assigned_for_interview_at with #{cu} login" <<
				" without ids" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			put :assign_selected_for_interview
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end

#		test "should NOT update assigned_for_interview_at with ids and #{cu} login" <<
#				" with invalid enrollment" do
#			login_as send(cu)
#			subject = subject_for_assigned_for_interview_at
#			Enrollment.any_instance.stubs(:valid?).returns(false)
#			put :assign_selected_for_interview, :ids => [subject.id]
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'index'
#			assert_nil subject.enrollments.where(
#				:project_id => Project[:ccls].id).first.assigned_for_interview_at
#		end
#
#		test "should NOT update assigned_for_interview_at with ids and #{cu} login" <<
#				" with failed enrollment save" do
#			login_as send(cu)
#			subject = subject_for_assigned_for_interview_at
#			Enrollment.any_instance.stubs(:create_or_update).returns(false)
#			put :assign_selected_for_interview, :ids => [subject.id]
#			assert_not_nil flash[:error]
#			assert_response :success
#			assert_template 'index'
#			assert_nil subject.enrollments.where(
#				:project_id => Project[:ccls].id).first.assigned_for_interview_at
#		end

	end


	non_site_editors.each do |cu|

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update selected with #{cu} login" do
			login_as send(cu)
			put :assign_selected_for_interview, :ids => [1,2,3]
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end


#	no login ...

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT update selected without login" do
		put :assign_selected_for_interview, :ids => [1,2,3]
		assert_redirected_to_login
	end


protected

	def subject_for_assigned_for_interview_at
#		subject = FactoryGirl.create(:case_study_subject)
#		FactoryGirl.create(:patient, :study_subject => subject,
#			:admit_date => 60.days.ago)
		subject = FactoryGirl.create(:patient, :admit_date => 60.days.ago).study_subject
		#	Pagan only wants subjects with reference_date/admit_date > 30 days ago
		#	updating admit_date should trigger reference_date update
		subject.enrollments.where(:project_id   => Project[:ccls].id).first
			.update_attributes({
				:is_eligible  => YNDK[:yes],
				:consented    => YNDK[:yes],
				:consented_on => Date.current
			})
		assert_equal 5, subject.phase
		assert_nil subject.enrollments.where(
			:project_id => Project[:ccls].id).first.assigned_for_interview_at
		subject
	end

end
__END__
