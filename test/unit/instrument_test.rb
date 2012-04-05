require 'test_helper'

class InstrumentTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many(:instrument_versions)
	assert_should_belong_to(:interview_method)
	assert_should_initially_belong_to(:project)

	attributes = %w( name position
		results_table_id interview_method_id
		began_use_on ended_use_on )
	required = %w( name )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :name, :maximum => 250 )
	assert_requires_complete_date( :began_use_on, :ended_use_on )

	test "explicit Factory instrument test" do
		assert_difference('Project.count',1) {
		assert_difference('Instrument.count',1) {
			instrument = Factory(:instrument)
			assert_not_nil instrument.project
			assert_equal 'Instrument Name', instrument.name
			assert_match /Key\d*/, instrument.key
			assert_match /Desc\d*/, instrument.description
		} }
	end

	#	unfortunately name is NOT unique so should change this
	test "should return name as to_s" do
		instrument = Instrument.new(:name => 'testing')
		assert_equal instrument.name, 'testing'
		assert_equal instrument.name, "#{instrument}"
	end

	test "should require project" do
		instrument = Instrument.new( :project => nil)
		assert !instrument.valid?
		assert !instrument.errors.include?(:project)
		assert  instrument.errors.matching?(:project_id,"can't be blank")
	end

	test "should require valid project" do
		instrument = Instrument.new( :project_id => 0)
		assert !instrument.valid?
		assert !instrument.errors.include?(:project_id)
		assert  instrument.errors.matching?(:project,"can't be blank")
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_instrument

end
