require 'test_helper'

class FollowUpTypeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many(:follow_ups)
	assert_should_not_require_attributes( :position )
#	assert_should_require_attribute_length( :event_category, :in => 4..250 )

	test "follow_up_type factory should create follow up type" do
		assert_difference('FollowUpType.count',1) {
			follow_up_type = FactoryGirl.create(:follow_up_type)
			assert_match /Key\d*/, follow_up_type.key
			assert_match /Desc\d*/, follow_up_type.description
		}
	end

	test "should return description as to_s" do
		follow_up_type = FollowUpType.new(:description => 'testing')
		assert_equal follow_up_type.description, 'testing'
		assert_equal follow_up_type.description, "#{follow_up_type}"
	end

protected

#	def create_follow_up_type(options={})
#		follow_up_type = FactoryGirl.build(:follow_up_type,options)
#		follow_up_type.save
#		follow_up_type
#	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_follow_up_type

end
