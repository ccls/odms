require 'test_helper'

class AddressTest < ActiveSupport::TestCase

	#	external_address_id isn't required so don't use class level test
	#	would have to modify class level test to try to put something
	#	in the field, but would have to determine datatype and ......
	test "should require unique external_address_id" do
		Factory(:address,:external_address_id => 123456789)
		address = Address.new(:external_address_id => 123456789)
		assert !address.valid?
		assert address.errors.matching?(:external_address_id,
			'has already been taken')
	end

	assert_should_create_default_object

	attributes = %w( line_1 line_2 unit city state zip county country external_address_id )
	required   = %w( line_1 city state zip )
	unique     = %w( external_address_id )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
#	assert_should_require_unique( unique )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( 
		:zip, 
			:maximum => 10 )
	assert_should_require_attribute_length( 
		:line_1, 
		:line_2, 
		:unit,
		:city, 
		:state,
			:maximum => 250 )

	assert_should_have_one(:addressing)
	assert_should_have_many(:interviews)
	assert_should_initially_belong_to(:address_type)

	test "address factory should create address" do
		assert_difference('Address.count',1) {
			address = Factory(:address)
			assert_match /Box \d*/, address.line_1
			assert_equal "Berkeley", address.city
			assert_equal "CA", address.state
			assert_equal "12345", address.zip
		}
	end

	test "address factory should create address type" do
		assert_difference('AddressType.count',1) {
			address = Factory(:address)
			assert_not_nil address.address_type
		}
	end

	test "mailing_address should create address" do
		assert_difference('Address.count',1) {
			address = Factory(:mailing_address)
		}
	end

	test "mailing_address should not create address type" do
		assert_difference('AddressType.count',0) {
			address = Factory(:mailing_address)
			assert_equal address.address_type, AddressType['mailing']
		}
	end

	test "residence_address should create address" do
		assert_difference('Address.count',1) {
			address = Factory(:residence_address)
		}
	end

	test "residence_address should create address type" do
		assert_difference('AddressType.count',0) {
			address = Factory(:residence_address)
			assert_equal address.address_type, AddressType['residence']
		}
	end

	test "should require address_type" do
		address = Address.new( :address_type => nil)
		assert !address.valid?
		assert !address.errors.include?(:address_type)
		assert  address.errors.matching?(:address_type_id, "can't be blank")
	end

	test "should require valid address_type" do
		address = Address.new( :address_type_id => 0)
		assert !address.valid?
		assert !address.errors.include?(:address_type_id)
		assert  address.errors.matching?(:address_type, "can't be blank")
	end

	test "should require 5 or 9 digit zip" do
		%w( asdf 1234 123456 1234Q ).each do |bad_zip|
			address = Address.new( :zip => bad_zip )
			assert !address.valid?
			assert address.errors.include?(:zip)
		end
		%w( 12345 12345-6789 123456789 ).each do |good_zip|
			address = Address.new( :zip => good_zip )
			address.valid?
			assert !address.errors.include?(:zip)
			assert address.zip =~ /\A\d{5}(-)?(\d{4})?\z/
		end
	end

	test "should format 9 digit zip" do
		assert_difference( "Address.count", 1 ) do
			address = create_address( :zip => '123456789' )
#			address = Address.new( :zip => '123456789' )
#			address.valid?
#	the formating is currently in a before save, so have to save it.
			assert !address.errors.include?(:zip)
			assert address.zip =~ /\A\d{5}(-)?(\d{4})?\z/
			assert_equal '12345-6789', address.zip
		end
	end

#	doesn't really matter
#	test "should order address chronologically reversed" do
#		a1 = Factory(:address, :created_at => Date.jd(2440000) ).id
#		a2 = Factory(:address, :created_at => Date.jd(2450000) ).id
#		a3 = Factory(:address, :created_at => Date.jd(2445000) ).id
##	dropped default scope
##		address_ids = Address.all.collect(&:id)
#		address_ids = Address.order('created_at DESC').all.collect(&:id)
#		assert_equal address_ids, [a2,a3,a1]
#	end

	test "should return city state and zip with csz" do
		address = Address.new(
			:city  => 'City',
			:state => 'CA',
			:zip   => '12345')
		assert_equal "City, CA 12345", address.csz
	end

	#	Note that there are probably legitimate address line 1's 
	#	that will match the p.*o.*box regex.
	test "should require non-residence address type with pobox in line" do
		["P.O. Box 123","PO Box 123","P O Box 123","Post Office Box 123"].each do |pobox|
			address = Address.new( 
				:line_1 => pobox,
				:address_type => AddressType['residence']
			)
			assert !address.valid?
			assert address.errors.include?(:address_type_id)
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_address

end
