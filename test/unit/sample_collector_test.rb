require 'test_helper'

class SampleCollectorTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to(:organization)

	test "explicit Factory sample_collector test" do
		assert_difference('Organization.count',1) {
		assert_difference('SampleCollector.count',1) {
			sample_collector = Factory(:sample_collector)
			assert_not_nil sample_collector.organization
		} }
	end

	test "should require organization" do
		assert_difference( "SampleCollector.count", 0 ) do
			sample_collector = create_sample_collector( :organization => nil)
			assert !sample_collector.errors.include?(:organization)
			assert  sample_collector.errors.matching?(:organization_id,"can't be blank")
		end
	end

	test "should require valid organization" do
		assert_difference( "SampleCollector.count", 0 ) do
			sample_collector = create_sample_collector( :organization_id => 0)
			assert !sample_collector.errors.include?(:organization_id)
			assert  sample_collector.errors.matching?(:organization,"can't be blank")
		end
	end

	test "should require other_organization if organization is other" do
		assert_difference( "SampleCollector.count", 0 ) do
			sample_collector = create_sample_collector( 
				:organization_id => Organization['other'].id )
			assert sample_collector.errors.include?(:other_organization)
			assert sample_collector.errors.matching?(:other_organization,"can't be blank")
		end
	end

	test "should return organization name as to_s if organization" do
		organization = create_organization
		sample_collector = create_sample_collector(:organization => organization)
		assert_not_nil sample_collector.organization
		assert_equal organization.name, "#{sample_collector}"
	end

#	If organization is required, this can't ever happen
#	test "should return Unknown as to_s if no organization" do
#		sample_collector = create_sample_collector
#		assert_nil sample_collector.reload.organization
#		assert_equal 'Unknown', "#{sample_collector}"
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_sample_collector

end
