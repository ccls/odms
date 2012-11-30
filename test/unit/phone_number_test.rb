require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase

#	assert_should_accept_only_good_values( :current_phone, :is_valid,
	assert_should_accept_only_good_values( :current_phone, 
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_create_default_object
	assert_should_act_as_list( :scope => :study_subject_id )
	assert_should_initially_belong_to( :study_subject, :phone_type, :data_source )

#	attributes = %w( phone_number position study_subject_id
#		is_primary is_valid
#		why_invalid is_verified how_verified
#		verified_on verified_by_uid current_phone )
	attributes = %w( phone_number position study_subject_id
		is_primary current_phone )
	required = %w( phone_number )
	protected_attributes = %w( study_subject_id study_subject )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes )
	assert_should_protect( protected_attributes )
	assert_should_not_protect( attributes - protected_attributes )

#	assert_should_require_attribute_length( :how_verified, :why_invalid, 
#		:maximum => 250 )

	test "phone_number factory should create phone number" do
		assert_difference('PhoneNumber.count',1) {
			phone_number = Factory(:phone_number)
			assert_match /\(\d{3}\) \d{3}-\d{4}/, phone_number.phone_number
#			assert_equal 1, phone_number.is_valid
#			assert         !phone_number.is_verified
		}
	end

	test "phone_number factory should create phone type" do
		assert_difference('PhoneType.count',1) {
			phone_number = Factory(:phone_number)
			assert_not_nil phone_number.phone_type
		}
	end

	test "phone_number factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			phone_number = Factory(:phone_number)
			assert_not_nil phone_number.study_subject
		}
	end

	test "phone_number factory should leave is_primary as nil" do
		phone_number = Factory.build(:phone_number)
		assert_nil phone_number.is_primary
	end

	test "primary_phone_number factory should set is_primary to true" do
		phone_number = Factory.build(:primary_phone_number)
		assert phone_number.is_primary
	end

	test "altername_phone_number factory should set is_primary to false" do
		phone_number = Factory.build(:alternate_phone_number)
		assert !phone_number.is_primary
	end

	test "should return phone number as to_s" do
		phone_number = PhoneNumber.new(:phone_number => '123456789')
		assert_equal phone_number.phone_number, '123456789'
		assert_equal phone_number.phone_number, "#{phone_number}"
	end

	test "should require other_data_source if data_source is other" do
		phone_number = PhoneNumber.new( :data_source => DataSource['Other'])
		assert !phone_number.valid?
		assert  phone_number.errors.matching?(:other_data_source,"can't be blank")
	end

	test "should NOT require other_data_source if data_source is not other" do
		phone_number = PhoneNumber.new( :data_source => DataSource['raf'])
		phone_number.valid?
		assert !phone_number.errors.matching?(:other_data_source,"can't be blank")
	end

	test "should require data_source" do
		phone_number = PhoneNumber.new( :data_source => nil)
		assert !phone_number.valid?
		assert !phone_number.errors.include?(:data_source)
		assert  phone_number.errors.matching?(:data_source_id,"can't be blank")
	end

	test "should require valid data_source" do
		phone_number = PhoneNumber.new( :data_source_id => 0)
		assert !phone_number.valid?
		assert !phone_number.errors.include?(:data_source_id)
		assert  phone_number.errors.matching?(:data_source,"can't be blank")
	end

	test "should require phone_type" do
		phone_number = PhoneNumber.new( :phone_type => nil)
		assert !phone_number.valid?
		assert !phone_number.errors.include?(:phone_type)
		assert  phone_number.errors.matching?(:phone_type_id,"can't be blank")
	end

	test "should require valid phone_type" do
		phone_number = PhoneNumber.new( :phone_type_id => 0)
		assert !phone_number.valid?
		assert !phone_number.errors.include?(:phone_type_id)
		assert  phone_number.errors.matching?(:phone_type,"can't be blank")
	end

	test "current_phone should default to 1" do
		phone_number = PhoneNumber.new
		assert_equal 1, phone_number.current_phone
	end

	test "current scope should only return current phone_numbers" do
		create_phone_number(:current_phone => YNDK[:yes])
		h = create_phone_number(:current_phone => YNDK[:no])
		create_phone_number(:current_phone => YNDK[:dk])
		phone_numbers = PhoneNumber.current
		assert_equal 2, phone_numbers.length
		assert !phone_numbers.include?(h)
		phone_numbers.each do |phone_number|
			assert [1,999].include?(phone_number.current_phone)
		end
	end

	test "historic scope should only return historic phone_numbers" do
		create_phone_number(:current_phone => YNDK[:yes])
		h = create_phone_number(:current_phone => YNDK[:no])
		create_phone_number(:current_phone => YNDK[:dk])
		phone_numbers = PhoneNumber.historic
		assert_equal 1, phone_numbers.length
		assert_equal h, phone_numbers.first
		phone_numbers.each do |phone_number|
			assert ![1,999].include?(phone_number.current_phone)
		end
	end

	test "primary scope should only return primary phone_numbers" do
		create_phone_number
		p = create_primary_phone_number
		create_alternate_phone_number
		phone_numbers = PhoneNumber.primary
		assert_equal 1, phone_numbers.length
		assert_equal p, phone_numbers.first
	end

	test "alternate scope should only return alternate phone_numbers" do
		create_phone_number
		p = create_primary_phone_number
		create_alternate_phone_number
		#	alternate is either NULL or false
		phone_numbers = PhoneNumber.alternate
		assert_equal 2, phone_numbers.length
		assert !phone_numbers.include?(p)
	end

	test "should not have multiple errors for blank phone number" do
		phone_number = PhoneNumber.new(:phone_number => '')
		assert !phone_number.valid?
		assert !phone_number.errors.matching?(:phone_number,'is invalid')
		assert  phone_number.errors.matching?(:phone_number,"can't be blank")
	end

	test "should require properly formated phone number" do
		[ 'asdf', 'me@some@where.com','12345678','12345678901' 
		].each do |bad_phone|
			phone_number = PhoneNumber.new(:phone_number => bad_phone)
			assert !phone_number.valid?
			assert  phone_number.errors.matching?(:phone_number,'is invalid')
		end
		[ "(123)456-7890", "1234567890", 
			"  1 asdf23,4()5\+67   8 9   0asdf" ].each do |good_phone|
			assert_difference( "PhoneNumber.count", 1 ) do
				phone_number = create_phone_number(:phone_number => good_phone)
				assert !phone_number.errors.matching?(:phone_number,'is invalid')
#	formatting is done before save so must save
				assert phone_number.reload.phone_number =~ /\A\(\d{3}\)\s+\d{3}-\d{4}\z/
				assert_equal '(123) 456-7890', phone_number.phone_number
			end
		end
	end

#	formatting is done before save so must save
	test "should format phone number" do
		assert_difference( "PhoneNumber.count", 1 ) do
			phone_number = create_phone_number( :phone_number => '1234567890' )
			assert !phone_number.errors.include?(:phone_number)
			assert phone_number.phone_number =~ /\A\(\d{3}\)\s+\d{3}-\d{4}\z/
			assert_equal '(123) 456-7890', phone_number.phone_number
		end
	end


#	[:yes,:nil].each do |yndk|
#		test "should NOT require why_invalid if is_valid is #{yndk}" do
#			phone_number = PhoneNumber.new(:is_valid => YNDK[yndk])
#			phone_number.valid?
#			assert !phone_number.errors.include?(:why_invalid)
#		end
#	end
#	[:no,:dk].each do |yndk|
#		test "should require why_invalid if is_valid is #{yndk}" do
#			phone_number = PhoneNumber.new(:is_valid => YNDK[yndk])
#			assert !phone_number.valid?
#			assert  phone_number.errors.include?(:why_invalid)
#		end
#	end
#
#	test "should NOT require how_verified if is_verified is false" do
#		phone_number = PhoneNumber.new(:is_verified => false)
#		phone_number.valid?
#		assert !phone_number.errors.include?(:how_verified)
#	end
#
#	test "should require how_verified if is_verified is true" do
#		phone_number = PhoneNumber.new(:is_verified => true)
#		assert !phone_number.valid?
#		assert  phone_number.errors.include?(:how_verified)
#	end
#
#	test "should NOT set verified_on if is_verified NOT changed to true" do
#		phone_number = create_phone_number(:is_verified => false)
#		assert_nil phone_number.verified_on
#	end
#
#	test "should set verified_on if is_verified changed to true" do
#		phone_number = create_phone_number(:is_verified => true,
#			:how_verified => "not a clue")
#		assert_not_nil phone_number.verified_on
#	end
#
#	test "should set verified_on to NIL if is_verified changed to false" do
#		phone_number = create_phone_number(:is_verified => true,
#			:how_verified => "not a clue")
#		assert_not_nil phone_number.verified_on
#		phone_number.update_attributes(:is_verified => false)
#		assert_nil phone_number.verified_on
#	end
#
#	test "should NOT set verified_by_uid if is_verified NOT changed to true" do
#		phone_number = create_phone_number(:is_verified => false)
#		assert_nil phone_number.verified_by_uid
#	end
#
#	test "should set verified_by_uid to 0 if is_verified changed to true" do
#		phone_number = create_phone_number(:is_verified => true,
#			:how_verified => "not a clue")
#		assert_not_nil phone_number.verified_by_uid
#		assert_equal phone_number.verified_by_uid, ''
#	end
#
#	test "should set verified_by_uid to current_user.id if is_verified " <<
#		"changed to true if current_user passed" do
#		cu = admin_user
#		phone_number = create_phone_number(:is_verified => true,
#			:current_user => cu,
#			:how_verified => "not a clue")
#		assert_not_nil phone_number.verified_by_uid
#		assert_equal phone_number.verified_by_uid, cu.uid
#	end
#
#	test "should set verified_by_uid to NIL if is_verified changed to false" do
#		phone_number = create_phone_number(:is_verified => true,
#			:how_verified => "not a clue")
#		assert_not_nil phone_number.verified_by_uid
#		phone_number.update_attributes(:is_verified => false)
#		assert_nil phone_number.verified_by_uid
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_phone_number

end
