require 'test_helper'

class InterviewOutcomeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many(:homex_outcomes)
	assert_should_not_require_attributes( :position )

	test "interview_outcome factory should create interview outcome" do
		assert_difference('InterviewOutcome.count',1) {
			interview_outcome = Factory(:interview_outcome)
			assert_match /Key\d*/,  interview_outcome.key
			assert_match /Desc\d*/, interview_outcome.description
		}
	end

	test "should return description as to_s" do
		interview_outcome = InterviewOutcome.new(:description => "testing")
		assert_equal interview_outcome.description, 'testing'
		assert_equal interview_outcome.description,
			"#{interview_outcome}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_interview_outcome

end
