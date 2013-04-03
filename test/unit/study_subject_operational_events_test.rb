require 'test_helper'

#	This is just a collection of race related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectOperationalEventsTest < ActiveSupport::TestCase

	test "should create newSubject operational event on creation" do
		study_subject = nil
		assert_difference('OperationalEventType.count',0) {	#	make sure it didn't create it
		assert_difference('OperationalEvent.count',1) {
		assert_difference('StudySubject.count',1) {
			study_subject = FactoryGirl.create(:study_subject)
		} } }
		events = study_subject.operational_events.where(
			:project_id => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['newSubject'].id)
		assert_equal 1, events.count
	end

	test "should create subjectDied operational event when vital status changed to deceased" do
		study_subject = FactoryGirl.create(:study_subject).reload
		assert_not_nil study_subject.vital_status
		assert_difference('OperationalEventType.count',0) {	#	make sure it didn't create it
		assert_difference('OperationalEvent.count',1) {
			study_subject.update_attributes(:vital_status_code => VitalStatus['deceased'].code)
		} }
		assert_equal study_subject.reload.vital_status, VitalStatus['deceased']
		events = study_subject.operational_events.where(
			:project_id => Project['ccls'].id).where(
			:operational_event_type_id => OperationalEventType['subjectDied'].id)
		assert_equal 1, events.count
	end

	test "should return nil for subject's screener_complete_date_for_open_project" <<
			" when subject has no associated operational event type" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_nil study_subject.screener_complete_date_for_open_project
	end

	test "should return date for subject's screener_complete_date_for_open_project" <<
			" when subject has associated operational event type" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_nil study_subject.screener_complete_date_for_open_project
		study_subject.operational_events.create(
			:project => Project['ccls'],
			:operational_event_type_id => OperationalEventType['screener_complete'].id,
			:occurred_at => DateTime.current )
#			:occurred_at => Date.current)
		date = study_subject.screener_complete_date_for_open_project
		assert_equal date, Date.current
	end

end
