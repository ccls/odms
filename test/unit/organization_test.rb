require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash( :value => :name )

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_not_require_attributes( :position )
	assert_should_have_many( :patients )
	assert_should_have_one(  :hospital )
	assert_should_have_one(  :sample_location )

	test "organization factory should create organization" do
		assert_difference('Organization.count',1) {
			organization = FactoryGirl.create(:organization)
			assert_match /Key \d*/,  organization.key
			assert_match /Name \d*/, organization.name
		}
	end

	test "should return name as to_s" do
		organization = Organization.new(:name => 'testing')
		assert_equal organization.name, 'testing'
		assert_equal organization.name, "#{organization}"
	end

	test "should be other if is other" do
		organization = Organization['other']
		assert organization.is_other?
	end

	test "should not be other if is not other" do
		organization = FactoryGirl.create(:organization)
		assert !organization.is_other?
	end

#	scope :without_hospital, joins('LEFT JOIN hospitals ON organizations.id = hospitals.organization_id').where('organization_id IS NULL')

#	scope :without_sample_location, joins('LEFT JOIN sample_locations ON organizations.id = sample_locations.organization_id').where('organization_id IS NULL')

	test "without_hospital should return only those without a hospital" do
		Organization.without_hospital.each do |org|
			assert_nil org.hospital
		end
	end

	test "without_sample_location should return only those without a sample_location" do
		Organization.without_sample_location.each do |org|
			assert_nil org.sample_location
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_organization

end
