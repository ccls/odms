require 'test_helper'

class IneligibleReasonTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list

	attributes = %w( position )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )

	test "ineligible_reason factory should create ineligible reason" do
		assert_difference('IneligibleReason.count',1) {
			ineligible_reason = FactoryGirl.create(:ineligible_reason)
			assert_match /Key\d*/, ineligible_reason.key
			assert_match /Desc\d*/, ineligible_reason.description
		}
	end

	test "should return description as to_s" do
		ineligible_reason = IneligibleReason.new(:description => 'testing')
		assert_equal ineligible_reason.description, 'testing'
		assert_equal ineligible_reason.description, "#{ineligible_reason}"
	end

	test "should find random" do
		ineligible_reason = IneligibleReason.random()
		assert ineligible_reason.is_a?(IneligibleReason)
	end

	test "should return nil on random when no records" do
		IneligibleReason.stubs(:count).returns(0)
		ineligible_reason = IneligibleReason.random()
		assert_nil ineligible_reason
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_ineligible_reason

end
