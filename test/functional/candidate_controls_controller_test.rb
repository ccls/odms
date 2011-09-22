require 'test_helper'

class CandidateControlsControllerTest < ActionController::TestCase

	test "case_study_subject creation test without patid" do
		case_study_subject = create_case_study_subject
		assert_nil case_study_subject.patid
	end

	test "case_study_subject creation test with patid" do
		case_study_subject = create_case_identifier.study_subject
		assert_not_nil case_study_subject.patid
	end

	site_editors.each do |cu|

		test "should get edit with #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.reload.patid)
			get :edit, :id => candidate.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT get edit with #{cu} login and invalid id" do
			login_as send(cu)
			get :edit, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end

		test "should NOT get edit with #{cu} login and no case" do
			login_as send(cu)
			candidate = create_candidate_control
			get :edit, :id => candidate.id
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end


		test "should put update with #{cu} login and mark candidate as rejected" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => true,
					:rejection_reason => 'Some fake reason.' }
			} }
			candidate.reload
			assert         candidate.reject_candidate
			assert_not_nil candidate.rejection_reason
			assert_nil     candidate.assigned_on
			assert_nil     candidate.study_subject_id
			assert_redirected_to case_path(case_study_subject.id)
		end

		test "should put update with #{cu} login and accept candidate" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('StudySubject.count',2) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => false }
			} }
			candidate.reload
			assert        !candidate.reject_candidate
			assert_nil     candidate.rejection_reason
			assert_not_nil candidate.assigned_on
			assert_not_nil candidate.study_subject
			assert_not_nil candidate.study_subject.mother
			assert_redirected_to case_path(case_study_subject.id)
		end

		test "should NOT put update with #{cu} login and accept candidate" <<
				" when StudySubject save fails" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => false )
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT put update with #{cu} login and accept candidate" <<
				" when StudySubject invalid" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => false )
			assert_response :success
			assert_template 'edit'
		end

#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Enrollment save fails" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#	#			Enrollment.any_instance.stubs(:create_or_update).returns(false)
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => false )
#	#			assert_response :success
#	#			assert_template 'edit'
#			end
#	
#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Enrollment invalid" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#	#			Enrollment.any_instance.stubs(:valid?).returns(false)
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => false )
#	#			assert_response :success
#	#			assert_template 'edit'
#			end
#	
#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Pii save fails" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#	#			Pii.any_instance.stubs(:create_or_update).returns(false)
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => false )
#	#			assert_response :success
#	#			assert_template 'edit'
#			end
#	
#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Pii invalid" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#	#			Pii.any_instance.stubs(:valid?).returns(false)
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => false )
#	#			assert_response :success
#	#			assert_template 'edit'
#			end
#	
#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Identifier save fails" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#	#			Identifier.any_instance.stubs(:create_or_update).returns(false)
#	##			StudySubject.any_instance.stubs(:autosave_associated_records_for_identifier).returns(false)
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => false )
#	#			assert_response :success
#	#			assert_template 'edit'
#			end
#		
#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Identifier invalid" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#				Identifier.any_instance.stubs(:valid?).returns(false)
#	#puts StudySubject.instance_methods.sort
#	#			StudySubject.any_instance.stubs(:validate_associated_records_for_identifier).raises(ActiveRecord::RecordInvalid)
#				StudySubject.any_instance.stubs(:validate_associated_records_for_identifier).returns(false)
#				assert_not_put_update_candidate(candidate, :reject_candidate => false )
#	#			assert_response :success
#	#			assert_template 'edit'
#	flunk
#			end
#
#	just can't get the stubs to work on nested attributes.


		test "should NOT put update with #{cu} login and empty attributes" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			assert_not_put_update_candidate(candidate)
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT put update with #{cu} login and invalid id" do
			login_as send(cu)
			assert_difference('StudySubject.count',0) {
				put :update, :id => 0, :candidate_control => {}
			}
			assert_not_nil flash[:error]
			assert_redirected_to cases_path
		end

		test "should NOT put update with #{cu} login and no case" do
			login_as send(cu)
			candidate = create_candidate_control
			assert_not_put_update_candidate(candidate)
			assert_redirected_to cases_path
		end

		test "should NOT put update with #{cu} login and invalid candidate" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			CandidateControl.any_instance.stubs(:valid?).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => false )
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT put update with #{cu} login and candidate save fails" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			CandidateControl.any_instance.stubs(:create_or_update).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => false )
			assert_response :success
			assert_template 'edit'
		end

		#	same as invalid candidate, but more explicit and obvious
		test "should NOT put update with #{cu} login and rejected without reason" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			assert_not_put_update_candidate(candidate, {
				:reject_candidate => true,
				:rejection_reason => '' })
			assert_response :success
			assert_template 'edit'
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get edit with #{cu} login" do
			login_as send(cu)
			candidate = create_candidate_control
			get :edit, :id => candidate.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT put update with #{cu} login" do
			login_as send(cu)
			candidate = create_candidate_control
			put :update, :id => candidate.id, :candidate_control => {}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	#	not logged in
	test "should NOT get edit without login" do
		candidate = create_candidate_control
		get :edit, :id => candidate.id
		assert_redirected_to_login
	end

	test "should NOT put update without login" do
		candidate = create_candidate_control
		put :update, :id => candidate.id, :candidate_control => {}
		assert_redirected_to_login
	end

protected

	def assert_not_put_update_candidate(candidate,options={})
		deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
		assert_difference('StudySubject.count',0) {
			put :update, :id => candidate.id, :candidate_control => options
		} }
		assert_not_nil flash[:error]
	end

end
