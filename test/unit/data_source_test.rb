require 'test_helper'

class DataSourceTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list

	attributes = %w( position organization_id other_organization
		person_id other_person data_origin )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( 
		:other_organization, 
		:other_person, 
		:data_origin, 
			:maximum => 250 )

	test "data_source should create data source" do
		assert_difference('DataSource.count',1) {
			data_source = Factory(:data_source)
			assert_match /Key\d*/, data_source.key
			assert_match /Desc\d*/, data_source.description
		}
	end

	test "should return description as to_s" do
		data_source = DataSource.new(:description => 'testing')
		assert_equal data_source.description, 'testing'
		assert_equal data_source.description,
			"#{data_source}"
	end

	test "should return true for is_other if is other" do
		data_source = DataSource['Other']
		assert data_source.is_other?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_data_source

end
