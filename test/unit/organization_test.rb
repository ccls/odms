require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash( :value => :name )

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_not_require_attributes( :position, :person_id )
	assert_should_belong_to( :person )
	assert_should_have_many( :patients )
#	assert_should_have_many( :hospitals )
	assert_should_have_one(  :hospital )
	assert_should_have_one(  :sample_location )

	assert_should_have_many(:aliquots, 
		:foreign_key => :owner_id)

	with_options :class_name => 'Transfer' do |o|
		o.assert_should_have_many(:incoming_transfers, 
			:foreign_key => :to_organization_id)
		o.assert_should_have_many(:outgoing_transfers, 
			:foreign_key => :from_organization_id)
	end

	test "organization factory should create organization" do
		assert_difference('Organization.count',1) {
			organization = Factory(:organization)
			assert_match /Key \d*/,  organization.key
			assert_match /Name \d*/, organization.name
		}
	end

	test "new incoming_transfer should have matching organization id" do
		organization = Factory(:organization)
		transfer = organization.incoming_transfers.build
		assert_equal organization.id, transfer.to_organization_id
	end

	test "new outgoing_transfer should have matching organization id" do
		organization = Factory(:organization)
		transfer = organization.outgoing_transfers.build
		assert_equal organization.id, transfer.from_organization_id
	end

#	TODO haven't really implemented organization samples yet
#	test "should have many samples" do
#		#	this is unclear in my diagram
#		skip
#	end

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
		organization = Factory(:organization)
		assert !organization.is_other?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_organization

end
