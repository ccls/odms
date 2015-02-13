require 'test_helper'

class IcfMasterTrackerTest < ActiveSupport::TestCase

	test "should update blank interview_completed_on with cati_complete if not blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')
		assert_equal Date.parse('12/31/2012'),study_subject.ccls_enrollment.reload.interview_completed_on
		assert_match /interview_completed_on set to/, icf_master_tracker.status
	end

	test "should NOT update blank interview_completed_on with cati_complete if blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST')
		assert_nil study_subject.ccls_enrollment.reload.interview_completed_on
		assert_match /cati_complete is blank/, icf_master_tracker.status
	end

#
#	NOTE update_column requires a date field to be given an actual date. 
#			It will not typecast it like update_attribute used to.
#

	test "should update different interview_completed_on with cati_complete if not blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		study_subject.ccls_enrollment.reload.update_column(:interview_completed_on, Date.parse('12/31/2000'))
		assert_not_nil study_subject.ccls_enrollment.reload.interview_completed_on
		assert_equal Date.parse('12/31/2000'),study_subject.ccls_enrollment.reload.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')
		assert_equal Date.parse('12/31/2012'),study_subject.ccls_enrollment.reload.interview_completed_on
		assert_match /interview_completed_on set to/, icf_master_tracker.status
	end

	test "should create operational event with cati_complete if not blank and changes interview_completed_on" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')

		#	could be more specific
		oes = study_subject.operational_events
			.where(:operational_event_type_id => OperationalEventType['other'].id)
		assert_equal 1, oes.length
		assert_match /interview_completed_on set to/, oes.first.description
		assert_match /interview_completed_on set to/, icf_master_tracker.status
	end

	test "should not create operational event with cati_complete if not blank and same interview_completed_on" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		study_subject.ccls_enrollment.reload.update_column(:interview_completed_on, Date.parse('12/31/2012'))
		assert_not_nil study_subject.ccls_enrollment.reload.interview_completed_on
		assert_equal Date.parse('12/31/2012'),study_subject.ccls_enrollment.reload.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')
		assert study_subject.operational_events
			.where(:operational_event_type_id => OperationalEventType['other'].id).empty?
		assert_match /No change so doing nothing/, icf_master_tracker.status
	end

	test "should do what if cati_complete blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST')
		assert_match /cati_complete is blank/, icf_master_tracker.status
	end

	test "should do what if master_id not valid" do
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IAMBOGUS')
		assert_match /No subject with icf_master_id/, icf_master_tracker.status
	end

	test "should do what if master_id blank" do
		icf_master_tracker = IcfMasterTracker.new(:master_id => '')
		assert_match /master_id is blank/, icf_master_tracker.status
	end

	test "should do what if master_id not given" do
		icf_master_tracker = IcfMasterTracker.new()
		assert_match /master_id is blank/, icf_master_tracker.status
	end

end
__END__
