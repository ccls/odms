require 'test_helper'

class RaceTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
#	assert_should_have_many( :study_subjects )
	assert_should_require_attributes( :code )
	assert_should_require_unique_attributes( :code )
	assert_should_not_require_attributes( :position )
#	assert_should_require_attribute_length( :code, :maximum => 250 )

	test "race factory should create race" do
		assert_difference('Race.count',1) {
			race = FactoryBot.create(:race)
			assert_match     /\d*/, race.code.to_s
			assert_match  /Key\d*/, race.key
			assert_match /Desc\d*/, race.description
		}
	end

	test "should return description as to_s" do
		race = Race.new(:description => 'testing')
		assert_equal race.description, 'testing'
		assert_equal race.description, "#{race}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_race

end
