require 'test_helper'

class UnitTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many( :aliquots, :samples )
	assert_should_belong_to( :context )
	assert_should_not_require_attributes( :position, :context_id )

	test "unit factory should create unit" do
		assert_difference('Unit.count',1) {
			unit = Factory(:unit)
			assert_match /Key\d*/, unit.key
			assert_match /Desc\d*/, unit.description
		}
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_unit

end
