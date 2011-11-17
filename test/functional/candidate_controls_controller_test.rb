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
			candidate = create_candidate_control(
				:related_patid => case_study_subject.reload.patid)
			assert_successful_edit(candidate)
		end

		test "should get edit with #{cu} login and preselect accept if matches sex and dob" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			dob = Date.today-1000
			Factory(:pii, :study_subject => case_study_subject, :dob => dob)
			candidate = create_candidate_control(
				:sex => case_study_subject.sex,
				:dob => dob,
				:related_patid => case_study_subject.reload.patid)
			assert_successful_edit(candidate)
			assert_select "input#candidate_control_reject_candidate_false", 1 do
				assert_select '[value=false]'
				assert_select "[checked=checked]"
			end
			assert_select "input#candidate_control_reject_candidate_true", 1 do
				assert_select '[value=true]'
			end
		end

		test "should get edit with #{cu} login and preselect reject if mismatched dob" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			dob = Date.today-1000
			Factory(:pii, :study_subject => case_study_subject, :dob => dob)
			candidate = create_candidate_control(
				:sex => case_study_subject.sex,
				:dob => dob-1,
				:related_patid => case_study_subject.reload.patid)
			assert_successful_edit(candidate)
			assert_select "input#candidate_control_reject_candidate_false", 1 do
				assert_select '[value=false]'
			end
			assert_select "input#candidate_control_reject_candidate_true", 1 do
				assert_select '[value=true]'
				assert_select "[checked=checked]"
			end
		end

		test "should get edit with #{cu} login and preselect reject if mismatched sex" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			dob = Date.today-1000
			Factory(:pii, :study_subject => case_study_subject, :dob => dob)
			candidate = create_candidate_control(
				:sex => (%w( M F ) - [case_study_subject.sex])[0],	#	the other sex
				:dob => dob,
				:related_patid => case_study_subject.reload.patid)
			assert_successful_edit(candidate)
			assert_select "input#candidate_control_reject_candidate_false", 1 do
				assert_select '[value=false]'
			end
			assert_select "input#candidate_control_reject_candidate_true", 1 do
				assert_select '[value=true]'
				assert_select "[checked=checked]"
			end
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

		test "should NOT get edit with #{cu} login and used candidate control" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(
				:related_patid => case_study_subject.reload.patid,
				:study_subject_id => case_study_subject.id )
			get :edit, :id => candidate.id
			assert_not_nil flash[:error]
			assert_redirected_to case_path(case_study_subject.id)
		end

		test "should put update with #{cu} login and mark candidate as rejected" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'true',
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
					:reject_candidate => 'false' }
			} }
			candidate.reload
			assert        !candidate.reject_candidate
			assert_nil     candidate.rejection_reason
			assert_not_nil candidate.assigned_on
			assert_not_nil candidate.study_subject
			assert_not_nil candidate.study_subject.mother
			assert_redirected_to case_path(case_study_subject.id)
		end

######################################################################
#
#	BEGIN DUPLICATE TESTS
#
#		controls will only be duplicates based on sex and dob (maybe maiden name)
#
		test "should NOT create control subject on update with duplicates and" <<
				" #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			duplicate = create_study_subject(:sex => candidate.sex,
				:pii_attributes => Factory.attributes_for(:pii,
					:dob => candidate.dob,
					:mother_maiden_name => candidate.mother_maiden_name) )
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('Pii.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }
			} } } }
			assert !assigns(:duplicates).empty?
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should create control subject on update with duplicates and" <<
				" 'No Match' and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			duplicate = create_study_subject(:sex => candidate.sex,
				:pii_attributes => Factory.attributes_for(:pii,
					:dob => candidate.dob,
					:mother_maiden_name => candidate.mother_maiden_name) )
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('Pii.count',2) {
			assert_difference('Identifier.count',2) {
			assert_difference('StudySubject.count',2) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' },
					:commit => 'No Match'
			} } } }
			assert !assigns(:duplicates)
			assert_redirected_to case_path(case_study_subject.id)
		end

		test "should NOT create control subject on update with duplicates and" <<
				" 'Match Found' and valid control duplicate_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			duplicate = create_study_subject(:sex => candidate.sex,
				:pii_attributes => Factory.attributes_for(:pii,
					:dob => candidate.dob,
					:mother_maiden_name => candidate.mother_maiden_name) )
			assert !duplicate.is_case?
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('Pii.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }, 
					:commit => 'Match Found', :duplicate_id => duplicate.id
			} } } }
			assert !assigns(:duplicates).empty?
			assert assigns(:duplicates).include?(duplicate)
			assert_redirected_to case_path(case_study_subject.id)
			assert candidate.reload.reject_candidate
			#	as the created duplicate is not explicitly a case
			#	the reason will be because it is a control
			assert_match /ineligible control - control already exists in system/, 
				candidate.rejection_reason
		end

		test "should NOT create control subject on update with duplicates and" <<
				" 'Match Found' and valid case duplicate_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			duplicate = create_study_subject(:sex => candidate.sex,
				:subject_type => SubjectType['Case'],
				:pii_attributes => Factory.attributes_for(:pii,
					:dob => candidate.dob,
					:mother_maiden_name => candidate.mother_maiden_name) )
			assert duplicate.is_case?
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('Pii.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }, 
					:commit => 'Match Found', :duplicate_id => duplicate.id
			} } } }
			assert !assigns(:duplicates).empty?
			assert assigns(:duplicates).include?(duplicate)
			assert_redirected_to case_path(case_study_subject.id)
			assert candidate.reload.reject_candidate
			assert_match /ineligible control - child is already a case subject/, 
				candidate.rejection_reason
		end

		test "should NOT create control subject on update with duplicates and" <<
				" 'Match Found' and no duplicate_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			duplicate = create_study_subject(:sex => candidate.sex,
				:pii_attributes => Factory.attributes_for(:pii,
					:dob => candidate.dob,
					:mother_maiden_name => candidate.mother_maiden_name) )
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('Pii.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }, 
					:commit => 'Match Found'
			} } } }
			assert !assigns(:duplicates).empty?
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
		end

		test "should NOT create control subject on update with duplicates and" <<
				" 'Match Found' and invalid duplicate_id and #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			duplicate = create_study_subject(:sex => candidate.sex,
				:pii_attributes => Factory.attributes_for(:pii,
					:dob => candidate.dob,
					:mother_maiden_name => candidate.mother_maiden_name) )
			deny_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('Pii.count',0) {
			assert_difference('Identifier.count',0) {
			assert_difference('StudySubject.count',0) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }, 
					:commit => 'Match Found', :duplicate_id => 0
			} } } }
			assert !assigns(:duplicates).empty?
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
			assert_not_nil flash[:warn]
		end
#
#	END DUPLICATE TESTS
#
######################################################################

		test "should assign icf_master_id on acceptance if available with #{cu} login" do
			Factory(:icf_master_id, :icf_master_id => '12345')
			Factory(:icf_master_id, :icf_master_id => '67890')
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('StudySubject.count',2) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }
			} }
			candidate.reload
			assert_not_nil candidate.study_subject.identifier.icf_master_id
			assert_equal '12345',
				candidate.study_subject.identifier.icf_master_id
			assert_not_nil candidate.study_subject.mother.identifier.icf_master_id
			assert_equal '67890',
				candidate.study_subject.mother.identifier.icf_master_id
			assert_nil flash[:warn]
		end

		test "should not assign icf_master_id to control on acceptance if none left " <<
				"with #{cu} login" do
			Factory(:icf_master_id, :icf_master_id => '12345')
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('StudySubject.count',2) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }
			} }
			candidate.reload
			assert_not_nil candidate.study_subject.identifier.icf_master_id
			assert_equal '12345',
				candidate.study_subject.identifier.icf_master_id
			assert_nil candidate.study_subject.mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should not assign icf_master_id to mother on acceptance if only one left " <<
				"with #{cu} login" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid,
				:updated_at => Date.yesterday)
			assert_changes("CandidateControl.find(#{candidate.id}).updated_at") {
			assert_difference('StudySubject.count',2) {
				put :update, :id => candidate.id, :candidate_control => {
					:reject_candidate => 'false' }
			} }
			candidate.reload
			assert_nil candidate.study_subject.identifier.icf_master_id
			assert_nil candidate.study_subject.mother.identifier.icf_master_id
			assert_not_nil flash[:warn]
		end

		test "should NOT put update with #{cu} login and accept candidate" <<
				" when StudySubject save fails" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			StudySubject.any_instance.stubs(:create_or_update).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT put update with #{cu} login and accept candidate" <<
				" when StudySubject invalid" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			StudySubject.any_instance.stubs(:valid?).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT put update with #{cu} login and used candidate control" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(
				:related_patid => case_study_subject.reload.patid,
				:study_subject_id => case_study_subject.id )
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
			assert_not_nil flash[:error]
			assert_redirected_to case_path(case_study_subject.id)
		end

#			test "should NOT put update with #{cu} login and accept candidate" <<
#					" when Enrollment save fails" do
#	pending
#				login_as send(cu)
#				case_study_subject = create_case_identifier.study_subject
#				candidate = create_candidate_control(:related_patid => case_study_subject.patid)
#	#			Enrollment.any_instance.stubs(:create_or_update).returns(false)
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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
#	#			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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
#				assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT put update with #{cu} login and candidate save fails" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			CandidateControl.any_instance.stubs(:create_or_update).returns(false)
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
			assert_response :success
			assert_template 'edit'
		end

		#	same as invalid candidate, but more explicit and obvious
		test "should NOT put update with #{cu} login and rejected without reason" do
			login_as send(cu)
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			assert_not_put_update_candidate(candidate, {
				:reject_candidate => 'true',
				:rejection_reason => '' })
			assert_response :success
			assert_template 'edit'
		end


		#	only cases get patids and this create controls, so only testing 
		#	duplicate childid and subjectid

		test "should do something if childid exists with #{cu} login" do
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			Identifier.any_instance.stubs(:get_next_childid).returns(12345)
			identifier1 = Factory(:identifier)
			assert_not_nil identifier1.childid
			login_as send(cu)
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
			assert_response :success
			assert_template 'edit'
		end

		test "should do something if subjectid exists with #{cu} login" do
			case_study_subject = create_case_identifier.study_subject
			candidate = create_candidate_control(:related_patid => case_study_subject.patid)
			Identifier.any_instance.stubs(:generate_subjectid).returns('012345')
			identifier1 = Factory(:identifier)
			assert_not_nil identifier1.subjectid
			login_as send(cu)
			assert_not_put_update_candidate(candidate, :reject_candidate => 'false' )
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

	def assert_successful_edit(candidate)
		get :edit, :id => candidate.id
		assert_nil flash[:error]
		assert_response :success
		assert_template 'edit'
	end

end
