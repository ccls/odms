require 'test_helper'

class IcfMasterTrackerTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_protect(:master_id)
	assert_should_require(:master_id)
	assert_should_require_unique(:master_id)
	assert_should_require_attribute_length( :last_update_attempt_errors, :maximum => 65000 )

	test "should not attach to study subject on create if none exists" do
		icf_master_tracker = Factory(:icf_master_tracker,
			:master_id => '1234')
		assert_nil icf_master_tracker.study_subject
	end

	test "should attach to study subject on create if exists" do
		icf_master_id = Factory(:icf_master_id, :icf_master_id => '1234')
		study_subject = Factory(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		icf_master_tracker = Factory(:icf_master_tracker,
			:master_id => '1234')
		assert_not_nil icf_master_tracker.study_subject
		assert_equal   icf_master_tracker.study_subject, study_subject
	end

	test "should attach to study subject on update if exists" do
		icf_master_tracker = Factory(:icf_master_tracker,
			:master_id => '1234')
		assert_nil icf_master_tracker.study_subject
		icf_master_id = Factory(:icf_master_id, :icf_master_id => '1234')
		study_subject = Factory(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		icf_master_tracker.save
		assert_not_nil icf_master_tracker.study_subject
		assert_equal   icf_master_tracker.study_subject, study_subject
	end

	test "should flag for update on create" do
		icf_master_tracker = Factory(:icf_master_tracker)
		assert icf_master_tracker.flagged_for_update
	end

#
#	update_attribute skipped attr_protection, but did trigger callbacks
#	update_column DOES NOT TRIGGER CALLBACKS
#

	test "should flag for update on change" do
		icf_master_tracker = Factory(:icf_master_tracker)
		assert  icf_master_tracker.flagged_for_update
		icf_master_tracker.update_attributes(:flagged_for_update => false)
		assert !icf_master_tracker.flagged_for_update
		icf_master_tracker.update_attributes(:is_eligible => 'trigger change')
		assert  icf_master_tracker.flagged_for_update
	end

	test "should NOT flag for update if no change" do
		icf_master_tracker = Factory(:icf_master_tracker)
		assert  icf_master_tracker.flagged_for_update
		icf_master_tracker.update_attributes(:flagged_for_update => false)
		assert !icf_master_tracker.flagged_for_update
		icf_master_tracker.save
		assert !icf_master_tracker.flagged_for_update
	end

	test "should return those flagged for update" do
		assert IcfMasterTracker.have_changed.empty?
		icf_master_tracker = Factory(:icf_master_tracker)
		assert IcfMasterTracker.have_changed.include?(
			icf_master_tracker )
		icf_master_tracker.update_attributes(:flagged_for_update => false)
		assert IcfMasterTracker.have_changed.empty?
	end

#	test "should create operational event for study subject if change" do
#		icf_master_id = Factory(:icf_master_id, :icf_master_id => '1234')
#		study_subject = Factory(:complete_case_study_subject)
#		study_subject.assign_icf_master_id
#		assert_difference('OperationalEvent.count',1) {
#			icf_master_tracker = Factory(:icf_master_tracker,
#				:master_id => '1234', :is_eligible => 'trigger change')
#			assert_not_nil icf_master_tracker.study_subject
#			assert_equal   icf_master_tracker.study_subject, study_subject
#			assert icf_master_tracker.study_subject.enrollments.find_by_project_id(
#				Project['ccls'].id).operational_events.collect(&:operational_event_type_id
#				).include?(OperationalEventType[:other].id)
#		}
#	end
#
#	test "should not create operational event for study subject if no change" do
#		icf_master_id = Factory(:icf_master_id, :icf_master_id => '1234')
#		study_subject = Factory(:complete_case_study_subject)
#		study_subject.assign_icf_master_id
#		assert_difference('OperationalEvent.count',0) {
#			icf_master_tracker = Factory(:icf_master_tracker,
#				:master_id => '1234')	#, :is_eligible => 'trigger change')
#			assert_not_nil icf_master_tracker.study_subject
#			assert_equal   icf_master_tracker.study_subject, study_subject
#			assert !icf_master_tracker.study_subject.enrollments.find_by_project_id(
#				Project['ccls'].id).operational_events.collect(&:operational_event_type_id
#				).include?(OperationalEventType[:other].id)
#		}
#	end

	test "should create one new icf_master_tracker_change record on create" do
		assert_difference('IcfMasterTracker.count',1) {
		assert_difference('IcfMasterTrackerChange.count',1) {
#	this will now be a "new_tracker_record" AND a "master_id" changed
#	the second is seemingly irrelevant so change callback
#		assert_difference('IcfMasterTrackerChange.count',2) {
			@icf_master_tracker = Factory(:icf_master_tracker)
		} }
		tracker_change = IcfMasterTrackerChange.first
		assert       tracker_change.new_tracker_record
		assert_equal tracker_change.icf_master_id, @icf_master_tracker.master_id
#		tracker_change = IcfMasterTrackerChange.last
#		assert      !tracker_change.new_tracker_record
	end

	test "should not create icf_master_tracker_change on save if no change" do
		icf_master_tracker = Factory(:icf_master_tracker)
		assert_difference('IcfMasterTracker.count',0) {
		assert_difference('IcfMasterTrackerChange.count',0) {
			icf_master_tracker.save
		} }
	end

	test "should create one icf_master_tracker_change on save if one change" do
		icf_master_tracker = Factory(:icf_master_tracker, :curr_phone => "something")
		assert_difference('IcfMasterTracker.count',0) {
		assert_difference('IcfMasterTrackerChange.count',1) {
			icf_master_tracker.update_attributes(:curr_phone => "something else")
		} }
		last_tracker = IcfMasterTrackerChange.last
		assert !last_tracker.new_tracker_record
		assert_equal last_tracker.modified_column, 'curr_phone'
		assert_equal last_tracker.previous_value, 'something'
		assert_equal last_tracker.new_value, 'something else'
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_icf_master_tracker

end
