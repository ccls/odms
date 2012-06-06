require 'test_helper'

class InstrumentVersionTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many( :interviews )
	assert_should_belong_to( :language, :instrument )
	assert_should_initially_belong_to( :instrument_type )

	attributes = %w( position language_id
		began_use_on ended_use_on instrument_id )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_requires_complete_date( :began_use_on, :ended_use_on )

	test "instrument_version factory should create instrument version" do
		assert_difference('InstrumentVersion.count',1) {
			instrument_version = Factory(:instrument_version)
			assert_match /Key\d*/, instrument_version.key
			assert_match /Desc\d*/, instrument_version.description
		}
	end

	test "instrument_version factory should create instrument type" do
		assert_difference('InstrumentType.count',1) {
			instrument_version = Factory(:instrument_version)
			assert_not_nil instrument_version.instrument_type
		}
	end

#	test "should require instrument_type" do
	test "should NOT require instrument_type" do
#		those in fixtures do have have
		instrument_version = InstrumentVersion.new( :instrument_type => nil)
#		assert !instrument_version.valid?
		instrument_version.valid?
		assert !instrument_version.errors.include?(:instrument_type)
#		assert  instrument_version.errors.matching?(:instrument_type_id,"can't be blank")
		assert !instrument_version.errors.include?(:instrument_type_id)
	end

	test "should require valid instrument_type" do
		instrument_version = InstrumentVersion.new( :instrument_type_id => 0)
		assert !instrument_version.valid?
		assert !instrument_version.errors.include?(:instrument_type_id)
		assert  instrument_version.errors.matching?(:instrument_type,"can't be blank")
	end

	test "should return description as to_s" do
		instrument_version = InstrumentVersion.new(:description => 'testing')
		assert_equal instrument_version.description, 'testing'
		assert_equal instrument_version.description, "#{instrument_version}"
	end

	test "should find random" do
		instrument_version = InstrumentVersion.random()
		assert instrument_version.is_a?(InstrumentVersion)
	end

	test "should return nil on random when no records" do
		InstrumentVersion.stubs(:count).returns(0)
		instrument_version = InstrumentVersion.random()
		assert_nil instrument_version
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_instrument_version

end
