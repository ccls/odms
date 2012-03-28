require 'test_helper'

class CountyTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_have_many(:zip_codes)

	attributes = %w( name state_abbrev fips_code )
	required   = %w( name state_abbrev )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_length( :name, :maximum => 250 )
	assert_should_require_length( :state_abbrev, :maximum => 2 )
	assert_should_require_length( :fips_code, :maximum => 5 )

	test "explicit Factory county test" do
		assert_difference('County.count',1) {
			county = Factory(:county)
			assert_match /Name \d*/, county.name
			assert_equal 'XX', county.state_abbrev
		}
	end

	test "should return name and state as to_s" do
		county = create_county
		assert_equal "#{county.name}, #{county.state_abbrev}", "#{county}"
	end

protected

#	def create_county(options={})
#		county = Factory.build(:county,options)
#		county.save
#		county
#	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_county

end
