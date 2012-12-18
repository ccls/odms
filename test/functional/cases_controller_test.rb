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

		test "should get index with blank assigned_for_interview_at and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :assigned_for_interview_at => ''
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with assigned_for_interview_at and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :assigned_for_interview_at => Date.today
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with invalid assigned_for_interview_at and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :assigned_for_interview_at => "FUNKAY MUNGKAY"
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with assigned_for_interview_at, exclusive ids" <<
				" and #{cu} login" do
			login_as send(cu)
			missed_subject = Factory(:study_subject)
			subject = subject_for_assigned_for_interview_at
			get :index, :assigned_for_interview_at => Date.today, :ids => [missed_subject.id]
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert !assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with assigned_for_interview_at, inclusive ids" <<
				" and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :assigned_for_interview_at => Date.today, :ids => [subject.id]
			assert_not_nil assigns(:study_subjects)
			assert !assigns(:study_subjects).empty?
			assert  assigns(:study_subjects).include?(subject)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with assigned_for_interview_at, invalid ids" <<
				" and #{cu} login" do
			login_as send(cu)
			subject = subject_for_assigned_for_interview_at
			get :index, :assigned_for_interview_at => Date.today, :ids => [99999]
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
				:project_id => Project['ccls'].id).first.assigned_for_interview_at


			assert_redirected_to cases_path(:ids => [subject.id])


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
#				:project_id => Project['ccls'].id).first.assigned_for_interview_at
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
#				:project_id => Project['ccls'].id).first.assigned_for_interview_at
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
			put :assign_selected_for_interview,
				:assigned_for_interview_at => Date.today, :ids => [1,2,3]
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
		put :assign_selected_for_interview,
			:assigned_for_interview_at => Date.today, :ids => [1,2,3]
		assert_redirected_to_login
	end


protected

	def subject_for_assigned_for_interview_at
		subject = Factory(:case_study_subject)
		subject.enrollments.where(
			:project_id   => Project['ccls'].id).first.update_attributes({
			:is_eligible  => YNDK[:yes],
			:consented    => YNDK[:yes],
			:consented_on => Date.today
		})
		assert_equal 5, subject.phase
		assert_nil subject.enrollments.where(
			:project_id => Project['ccls'].id).first.assigned_for_interview_at
		subject
	end

end
__END__
