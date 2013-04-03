require 'test_helper'

class InstrumentTypeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_have_many(:instrument_versions)
	assert_should_initially_belong_to(:project)
	assert_should_not_require_attributes( :position )

	test "instrument_type factory should instrument type" do
		assert_difference('InstrumentType.count',1) {
			instrument_type = FactoryGirl.create(:instrument_type)
			assert_match /Key\d*/, instrument_type.key
			assert_match /Desc\d*/, instrument_type.description
		}
	end

	test "instrument_type factory should project" do
		assert_difference('Project.count',1) {
			instrument_type = FactoryGirl.create(:instrument_type)
			assert_not_nil instrument_type.project
		}
	end

#	test "should require project" do
	test "should NOT require project" do
		instrument_type = InstrumentType.new( :project => nil)
#		assert !instrument_type.valid?
		instrument_type.valid?
		assert !instrument_type.errors.include?(:project)
#		assert  instrument_type.errors.matching?(:project_id,"can't be blank")
		assert !instrument_type.errors.include?(:project_id)
	end

	test "should require valid project" do
		instrument_type = InstrumentType.new( :project_id => 0)
		assert !instrument_type.valid?
		assert !instrument_type.errors.include?(:project_id)
		assert  instrument_type.errors.matching?(:project,"can't be blank")
	end

	test "should return description as to_s" do
		instrument_type = InstrumentType.new(:description => 'testing')
		assert_equal instrument_type.description, 'testing'
		assert_equal instrument_type.description, "#{instrument_type}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_instrument_type

end
