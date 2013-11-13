require 'test_helper'

class AddressTest < ActiveSupport::TestCase

	#	external_address_id isn't required so don't use class level test
	#	would have to modify class level test to try to put something
	#	in the field, but would have to determine datatype and ......
	test "should require unique external_address_id" do
		FactoryGirl.create(:address,:external_address_id => 123456789)
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

#	assert_should_have_one(:addressing)
	assert_should_have_many(:interviews)

	assert_should_accept_only_good_values( :address_type,
		{ :good_values => Address.valid_address_types, 
			:bad_values  => "I'm not valid" })

	test "address factory should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:address)
			assert_match /Box \d*/, address.line_1
			assert_equal "Berkeley", address.city
			assert_equal "CA", address.state
			assert_equal "12345", address.zip
		}
	end

	test "mailing_address should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:mailing_address)
		}
	end

	test "residence_address should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:residence_address)
		}
	end

	test "should require address_type" do
		address = Address.new( :address_type => nil)
		assert !address.valid?
		assert  address.errors.matching?(:address_type, "can't be blank")
	end

	test "should require 5 or 9 digit zip" do
		%w( asdf 1234 123456 1234Q ).each do |bad_zip|
			address = Address.new( :zip => bad_zip )
			assert !address.valid?
			assert address.errors.include?(:zip)
			assert address.errors.matching?(:zip,
				'Zip should be 12345, 123451234 or 12345-1234'), 
					address.errors.full_messages.to_sentence
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
#		a1 = FactoryGirl.create(:address, :created_at => Date.jd(2440000) ).id
#		a2 = FactoryGirl.create(:address, :created_at => Date.jd(2450000) ).id
#		a3 = FactoryGirl.create(:address, :created_at => Date.jd(2445000) ).id
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

	test "should return street with just line_1 if line_2 blank" do
		address = Address.new( :line_1   => 'I am line_1')
		assert_equal "I am line_1", address.street
	end

	test "should return street with join of line_1 and line_2" do
		address = Address.new( 
			:line_1   => 'I am line_1',
			:line_2   => 'I am line_2')
		assert_equal "I am line_1, I am line_2", address.street
	end

	#	Note that there are probably legitimate address line 1's 
	#	that will match the p.*o.*box regex.
	test "should require non-residence address type with pobox in line" do
		["P.O. Box 123","PO Box 123","P O Box 123","Post Office Box 123"].each do |pobox|
			address = Address.new( 
				:line_1 => pobox,
				:address_type => 'Residence'
			)
			assert !address.valid?
			assert address.errors.include?(:address_type)
		end
	end

#	test "should flag study subject for reindexed on create" do
#		address = FactoryGirl.create(:addressing).reload.address
#		assert_not_nil address.study_subject
#		assert address.study_subject.needs_reindexed
#	end
#
#	test "should flag study subject for reindexed on update" do
#		address = FactoryGirl.create(:addressing).reload.address
#		assert_not_nil address.study_subject
#		assert  address.study_subject.needs_reindexed
#		address.study_subject.update_attribute(:needs_reindexed, false)
#		assert !address.study_subject.needs_reindexed
#		address.update_attributes(:line_1 => "Someplace else")
#		assert  address.study_subject.needs_reindexed
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_address

end
