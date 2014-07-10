require 'test_helper'

class AlternateContactTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to( :study_subject )

	test "should require properly formated phone number 1" do
		[ 'asdf', 'me@some@where.com','12345678','12345678901' 
		].each do |bad_phone|
			alternate_contact = AlternateContact.new(:phone_number_1 => bad_phone)
			assert !alternate_contact.valid?
			assert  alternate_contact.errors.matching?(:phone_number_1,'is invalid')
		end
		[ "(123)456-7890", "1234567890", 
			"  1 asdf23,4()5\+67   8 9   0asdf" ].each do |good_phone|
			assert_difference( "AlternateContact.count", 1 ) do
				alternate_contact = create_alternate_contact(:phone_number_1 => good_phone)
				assert !alternate_contact.errors.matching?(:phone_number_1,'is invalid')
				#	formatting is done before save so must save
				assert alternate_contact.reload.phone_number_1 =~ /\A\(\d{3}\)\s+\d{3}-\d{4}\z/
				assert_equal '(123) 456-7890', alternate_contact.phone_number_1
			end
		end
	end

	test "should require properly formated phone number 2" do
		[ 'asdf', 'me@some@where.com','12345678','12345678901' 
		].each do |bad_phone|
			alternate_contact = AlternateContact.new(:phone_number_2 => bad_phone)
			assert !alternate_contact.valid?
			assert  alternate_contact.errors.matching?(:phone_number_2,'is invalid')
		end
		[ "(123)456-7890", "1234567890", 
			"  1 asdf23,4()5\+67   8 9   0asdf" ].each do |good_phone|
			assert_difference( "AlternateContact.count", 1 ) do
				alternate_contact = create_alternate_contact(:phone_number_2 => good_phone)
				assert !alternate_contact.errors.matching?(:phone_number_2,'is invalid')
				#	formatting is done before save so must save
				assert alternate_contact.reload.phone_number_2 =~ /\A\(\d{3}\)\s+\d{3}-\d{4}\z/
				assert_equal '(123) 456-7890', alternate_contact.phone_number_2
			end
		end
	end

#	formatting is done before save so must save
	test "should format phone number 1" do
		assert_difference( "AlternateContact.count", 1 ) do
			alternate_contact = create_alternate_contact( :phone_number_1 => '1234567890' )
			assert !alternate_contact.errors.include?(:phone_number_1)
			assert alternate_contact.phone_number_1 =~ /\A\(\d{3}\)\s+\d{3}-\d{4}\z/
			assert_equal '(123) 456-7890', alternate_contact.phone_number_1
		end
	end

	test "should format phone number 2" do
		assert_difference( "AlternateContact.count", 1 ) do
			alternate_contact = create_alternate_contact( :phone_number_2 => '1234567890' )
			assert !alternate_contact.errors.include?(:phone_number_2)
			assert alternate_contact.phone_number_2 =~ /\A\(\d{3}\)\s+\d{3}-\d{4}\z/
			assert_equal '(123) 456-7890', alternate_contact.phone_number_2
		end
	end

	test "should return city state and zip with csz" do
		alternate_contact = AlternateContact.new(
			:city  => 'City',
			:state => 'CA',
			:zip   => '12345')
		assert_equal "City, CA 12345", alternate_contact.csz
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_alternate_contact

end
