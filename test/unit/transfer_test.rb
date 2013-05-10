require 'test_helper'

class TransferTest < ActiveSupport::TestCase
#
#	assert_should_create_default_object
#	assert_should_initially_belong_to( :aliquot )
#	assert_should_initially_belong_to( :to_organization, :from_organization, 
#		:class_name => 'Organization' )
##	assert_should_require_attributes( :aliquot_id, 
##		:from_organization_id, :to_organization_id )
#
#	attributes = %w( position amount reason is_permanent )
#	assert_should_not_require( attributes )
#	assert_should_not_require_unique( attributes )
#	assert_should_not_protect( attributes )
#
#	assert_should_require_attribute_length( :reason, :maximum => 250 )
#
#	test "transfer factory should create transfer" do
#		assert_difference('Transfer.count',1) {
#			transfer = FactoryGirl.create(:transfer)
#		}
#	end
#
#	test "transfer factory should create aliquot" do
#		assert_difference('Aliquot.count',1) {
#			transfer = FactoryGirl.create(:transfer)
#			assert_not_nil transfer.aliquot
#		}
#	end
#
#	test "transfer factory should create 3 organizations" do
#		assert_difference('Organization.count',3) {	#	aliquot also creates an Organization
#			transfer = FactoryGirl.create(:transfer)
#			assert_not_nil transfer.from_organization
#			assert_not_nil transfer.to_organization
#		}
#	end
#
#	test "should require aliquot" do
#		transfer = Transfer.new( :aliquot => nil)
#		assert !transfer.valid?
#		assert !transfer.errors.include?(:aliquot)
#		assert  transfer.errors.matching?(:aliquot_id,"can't be blank")
#	end
#
#	test "should require valid aliquot" do
#		transfer = Transfer.new( :aliquot_id => 0)
#		assert !transfer.valid?
#		assert !transfer.errors.include?(:aliquot_id)
#		assert  transfer.errors.matching?(:aliquot,"can't be blank")
#	end
#
#	test "should require from_organization" do
#		transfer = Transfer.new( :from_organization => nil)
#		assert !transfer.valid?
#		assert !transfer.errors.include?(:from_organization)
#		assert  transfer.errors.matching?(:from_organization_id,"can't be blank")
#	end
#
#	test "should require valid from_organization" do
#		transfer = Transfer.new( :from_organization_id => 0)
#		assert !transfer.valid?
#		assert !transfer.errors.include?(:from_organization_id)
#		assert  transfer.errors.matching?(:from_organization,"can't be blank")
#	end
#
#	test "should require to_organization" do
#		transfer = Transfer.new( :to_organization => nil)
#		assert !transfer.valid?
#		assert !transfer.errors.include?(:to_organization)
#		assert  transfer.errors.matching?(:to_organization_id,"can't be blank")
#	end
#
#	test "should require valid to_organization" do
#		transfer = Transfer.new( :to_organization_id => 0)
#		assert !transfer.valid?
#		assert !transfer.errors.include?(:to_organization_id)
#		assert  transfer.errors.matching?(:to_organization,"can't be blank")
#	end
#
#protected
#
#	#	create_object is called from within the common class tests
#	alias_method :create_object, :create_transfer
#
end
