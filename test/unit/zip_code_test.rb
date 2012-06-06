require 'test_helper'

#
#	FYI, csv fixture files do not allow for comments
#
class ZipCodeTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_belong_to(:county)

	attributes = %w( zip_code city state zip_class )
	required   = %w( zip_code city state zip_class )
	unique     = %w( zip_code )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
	assert_should_require_unique( unique )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :zip_code, :is => 5 )
	assert_should_require_attribute_length( :city, :state, :zip_class,
		:maximum => 250 )

	test "zip_code factory should create zip code" do
		assert_difference('ZipCode.count',1) {
			zip_code = Factory(:zip_code)
			assert_match /X\d{4}/, zip_code.zip_code
			assert_match /\d{5}/,  zip_code.city
			assert_match /\d{5}/,  zip_code.state
			assert_equal 'TESTING', zip_code.zip_class
		}
	end

	test "should return city, state zip as to_s" do
		zip_code = create_zip_code
		assert_equal "#{zip_code.city}, #{zip_code.state} #{zip_code.zip_code}", "#{zip_code}"
	end

	test "should not find non-existant zip code with ['string']" do
		assert_nil ZipCode['94700']
	end

	test "should find by zip code with ['string']" do
		Factory(:zip_code,:zip_code => '94700')
		zip_code = ZipCode['94700']
		assert zip_code.is_a?(ZipCode)
	end

	test "should find by zip code with [:symbol]" do
		Factory(:zip_code,:zip_code => '94700')
		zip_code = ZipCode['94700'.to_sym]	#	:1 is no good, but '1'.to_sym is OK
		assert zip_code.is_a?(ZipCode)
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_zip_code

end
