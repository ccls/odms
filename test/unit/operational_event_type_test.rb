require 'test_helper'

class OperationalEventTypeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many(:operational_events)
	assert_should_not_require_attributes( :position )	#, :project_id )
	assert_should_require_attribute( :event_category )
	assert_should_require_attribute_length( :event_category, :in => 4..250 )

	test "operational_event_type factory should create operational event type" do
		assert_difference('OperationalEventType.count',1) {
			operational_event_type = FactoryGirl.create(:operational_event_type)
			assert_match /Key\d*/,  operational_event_type.key
			assert_match /Desc\d*/, operational_event_type.description
			assert_match /Cat\d*/,  operational_event_type.event_category
		}
	end

#	test "should return event_category as to_s" do
#		operational_event_type = create_operational_event_type
#		assert_equal operational_event_type.event_category, "#{operational_event_type}"
#	end

	test "should return event_category and description as to_s" do
		operational_event_type = create_operational_event_type
		assert_equal "#{operational_event_type}",
			"#{operational_event_type.event_category}:#{operational_event_type.description}"
	end

	test "categories should return a unique, sorted array of event categories" do
#["ascertainment", "compensation", "completions", "correspondence", "enrollments", "interviews", "operations", "recruitment", "samples"]
		categories = OperationalEventType.categories
		assert categories.is_a?(Array)
		assert !categories.empty?
		categories.each do |category|
			assert category.is_a?(String)
		end
	end

	#	NOTE event_category is required
	test "should return operational_event_types with blank category" do
		operational_event_type = FactoryGirl.create(:operational_event_type)
		operational_event_types = OperationalEventType.with_category()
		assert operational_event_types.include?(operational_event_type)
	end

	test "should return operational_event_types with 'example' category" do
		operational_event_type1 = FactoryGirl.create(:operational_event_type)
		operational_event_type2 = FactoryGirl.create(:operational_event_type,
			:event_category => 'example')
		operational_event_types = OperationalEventType.with_category('example')
		assert !operational_event_types.include?(operational_event_type1)
		assert  operational_event_types.include?(operational_event_type2)
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_operational_event_type

end
