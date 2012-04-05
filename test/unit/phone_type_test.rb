require 'test_helper'

class PhoneTypeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many(:phone_numbers)
	assert_should_not_require_attributes( :position )

	test "explicit Factory phone_type test" do
		assert_difference('PhoneType.count',1) {
			phone_type = Factory(:phone_type)
			assert_match /Key\d*/, phone_type.key
		}
	end

	test "should return key as to_s" do
		phone_type = PhoneType.new(:key => 'testing')
		assert_equal phone_type.key, 'testing'
		assert_equal phone_type.key, "#{phone_type}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_phone_type

end
