require 'test_helper'

class HomexOutcomeTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_belong_to( :study_subject )
	assert_should_protect( :study_subject_id, :study_subject )
	assert_requires_complete_date( 
		:interview_outcome_on, 
		:sample_outcome_on )
	assert_should_not_require_attributes( 
		:position,
		:study_subject_id,
		:sample_outcome,
		:sample_outcome_on,
		:interview_outcome,
		:interview_outcome_on )

	assert_should_accept_only_good_values( :interview_outcome,
		{ :good_values => ( HomexOutcome.valid_interview_outcomes + [nil] ), 
			:bad_values  => "I'm not valid" })

	assert_should_accept_only_good_values( :sample_outcome,
		{ :good_values => ( HomexOutcome.valid_sample_outcomes + [nil] ), 
			:bad_values  => "I'm not valid" })

	test "homex_outcome factory should create homex outcome" do
		assert_difference('HomexOutcome.count',1) {
			homex_outcome = FactoryGirl.create(:homex_outcome)
			assert_nil     homex_outcome.sample_outcome
			assert_not_nil homex_outcome.sample_outcome_on	#	because of SampleOutcome test
			assert_nil     homex_outcome.interview_outcome
			assert_not_nil homex_outcome.interview_outcome_on	#	because of InterviewOutcome test
		}
	end

	test "should require unique study_subject_id" do
		study_subject = FactoryGirl.create(:study_subject)
		create_homex_outcome(:study_subject => study_subject)
		assert_difference( "HomexOutcome.count", 0 ) do
			homex_outcome = create_homex_outcome(:study_subject => study_subject)
			assert homex_outcome.errors.include?(:study_subject_id)
		end
	end

	test "should require interview_outcome_on if interview_outcome?" do
		homex_outcome = HomexOutcome.new(
			:interview_outcome_on => nil,
			:interview_outcome    => 'hi there')
		assert !homex_outcome.valid?
		assert homex_outcome.errors.include?(:interview_outcome_on)
	end

	test "should require sample_outcome_on if sample_outcome?" do
		homex_outcome = HomexOutcome.new(
			:sample_outcome_on => nil,
			:sample_outcome    => 'hello yourself')
		assert !homex_outcome.valid?
		assert homex_outcome.errors.include?(:sample_outcome_on)
	end

	test "should create operational event when interview scheduled" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',1) do
			homex_outcome.update_attributes(
				:interview_outcome_on => past_date,
				:interview_outcome    => 'interview has been scheduled')
		end
		oe = OperationalEvent.last
		assert_equal 'scheduled', oe.operational_event_type.key
		assert_equal past_date,   oe.occurred_on
		assert_equal homex_outcome.study_subject_id, oe.study_subject_id
	end

	test "should create operational event when interview completed" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',1) do
			homex_outcome.update_attributes(
				:interview_outcome_on => past_date,
				:interview_outcome    => 'complete')
		end
		oe = OperationalEvent.last
		assert_equal 'iv_complete', oe.operational_event_type.key
		assert_equal past_date,   oe.occurred_on
		assert_equal homex_outcome.study_subject_id, oe.study_subject_id
	end

	test "should NOT create operational event when interview 'interview is incomplete'" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',0) do
			homex_outcome.update_attributes(
				:interview_outcome_on => past_date,
				:interview_outcome    => 'interview is incomplete')
		end
	end

	test "should NOT create operational event when interview pending" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',0) do
			homex_outcome.update_attributes(
				:interview_outcome_on => past_date,
				:interview_outcome    => 'pending')
		end
	end

	test "should raise NoHomeExposureEnrollment on create_interview_outcome_update" <<
			" if no enrollment in HomeExposures" do
		study_subject = FactoryGirl.create(:study_subject)
		homex_outcome = FactoryGirl.create(:homex_outcome,:study_subject => study_subject)
		assert_nil study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
		assert_raises(HomexOutcome::NoHomeExposureEnrollment){
			homex_outcome.update_attributes(
				:interview_outcome_on => Date.parse('Jan 15 2003'),
				:interview_outcome    => 'complete')
		}
	end

	test "should create operational event when sample kit sent" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',1) do
			homex_outcome.update_attributes(
				:sample_outcome_on => past_date,
				:sample_outcome    => 'kit sent')
		end
		oe = OperationalEvent.last
		assert_equal 'kit_sent', oe.operational_event_type.key
		assert_equal past_date,  oe.occurred_on
		assert_equal homex_outcome.study_subject_id, oe.study_subject_id
	end

	test "should create operational event when sample received" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',1) do
			homex_outcome.update_attributes(
				:sample_outcome_on => past_date,
				:sample_outcome    => 'sample received')
		end
		oe = OperationalEvent.last
		assert_equal 'sample_received', oe.operational_event_type.key
		assert_equal past_date,  oe.occurred_on
		assert_equal homex_outcome.study_subject_id, oe.study_subject_id
	end

	test "should create operational event when sample complete" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',1) do
			homex_outcome.update_attributes(
				:sample_outcome_on => past_date,
				:sample_outcome    => 'complete')
		end
		oe = OperationalEvent.last
		assert_equal 'sample_complete', oe.operational_event_type.key
		assert_equal past_date,  oe.occurred_on
		assert_equal homex_outcome.study_subject_id, oe.study_subject_id
	end

	test "should NOT create operational event when sample pending" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',0) do
			homex_outcome.update_attributes(
				:sample_outcome_on => past_date,
				:sample_outcome    => 'pending')
		end
	end

	test "should NOT create operational event when sample 'to lab'" do
		homex_outcome = create_complete_homex_outcome
		#	arbitrary past date
		past_date = Date.parse('Jan 15 2003')
		assert_difference('OperationalEvent.count',0) do
			homex_outcome.update_attributes(
				:sample_outcome_on => past_date,
				:sample_outcome    => 'to lab')
		end
	end

	test "should raise NoHomeExposureEnrollment on create_sample_outcome_update" <<
			" if no enrollment in HomeExposures" do
		study_subject = FactoryGirl.create(:study_subject)
		homex_outcome = FactoryGirl.create(:homex_outcome,:study_subject => study_subject)
		assert_nil study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
		assert_raises(HomexOutcome::NoHomeExposureEnrollment){
			homex_outcome.update_attributes(
				:sample_outcome_on => Date.parse('Jan 15 2003'),
				:sample_outcome    => 'complete')
		}
	end

	test "should return an array for interview_outcomes" do
		homex_outcome = HomexOutcome.new
		assert homex_outcome.interview_outcomes.is_a? Array
	end

	test "should return an array for sample_outcomes" do
		homex_outcome = HomexOutcome.new
		assert homex_outcome.sample_outcomes.is_a? Array
	end

protected

	def create_complete_homex_outcome(options={})
		s = FactoryGirl.create(:study_subject,options[:study_subject]||{})
		p = Project.find_or_create_by(key: 'HomeExposures')
		FactoryGirl.create(:enrollment, :study_subject => s, :project => p )
		h = create_homex_outcome(
			(options[:homex_outcome]||{}).merge(:study_subject => s,
			:interview_outcome_on => nil,
			:sample_outcome_on => nil))
		h
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_homex_outcome

end
