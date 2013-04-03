require 'test_helper'

class SampleLocationTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_initially_belong_to(:organization)
	assert_should_not_require_attributes( :position )
	assert_should_require_unique_attributes( :organization_id )

	test "sample_location factory should create organization" do
		assert_difference('Organization.count',1) {
			sample_location = FactoryGirl.create(:sample_location)
			assert_not_nil sample_location.organization
		}
	end

	test "should require organization" do
		sample_location = SampleLocation.new( :organization => nil)
		assert !sample_location.valid?
		assert !sample_location.errors.include?(:organization)
		assert  sample_location.errors.matching?(:organization_id,"can't be blank")
	end

	test "should require valid organization" do
		sample_location = SampleLocation.new( :organization_id => 0)
		assert !sample_location.valid?
		assert !sample_location.errors.include?(:organization_id)
		assert  sample_location.errors.matching?(:organization,"can't be blank")
	end

	test "should return organization name as to_s if organization" do
		organization = create_organization
		sample_location = SampleLocation.new(:organization => organization)
		assert_not_nil sample_location.organization
		assert_equal organization.name, "#{sample_location}"
	end

#	If organization is required, this can't ever happen
#	test "should return Unknown as to_s if no organization" do
#		sample_location = create_sample_location
#		assert_nil sample_location.reload.organization
#		assert_equal 'Unknown', "#{sample_location}"
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_sample_location

end
