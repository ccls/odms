require 'test_helper'

class RefusalReasonTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

#	Only IF study_subject not consented
#	assert_should_have_many(:enrollments)

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_not_require_attributes( :position )

	test "refusal_reason factory should create refusal reason" do
		assert_difference('RefusalReason.count',1) {
			refusal_reason = FactoryGirl.create(:refusal_reason)
			assert_match /Key\d*/, refusal_reason.key
			assert_match /Desc\d*/, refusal_reason.description
		}
	end

	test "should return description as to_s" do
		refusal_reason = RefusalReason.new(:description => 'testing')
		assert_equal refusal_reason.description, 'testing'
		assert_equal refusal_reason.description, "#{refusal_reason}"
	end

	test "should find random" do
		refusal_reason = RefusalReason.random()
		assert refusal_reason.is_a?(RefusalReason)
	end

	test "should return nil on random when no records" do
#		RefusalReason.destroy_all
		RefusalReason.stubs(:count).returns(0)
		refusal_reason = RefusalReason.random()
		assert_nil refusal_reason
	end

	test "should return true for is_other if is other" do
		refusal_reason = RefusalReason['Other']
		assert refusal_reason.is_other?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_refusal_reason

end
