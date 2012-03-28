require 'test_helper'

class ContextDataSourceTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to( :context, :data_source )

	test "explicit Factory context_data_source test" do
		assert_difference('DataSource.count',1) {
		assert_difference('Context.count',1) {
		assert_difference('ContextDataSource.count',1) {
			context_data_source = Factory(:context_data_source)
			assert_not_nil context_data_source.context
			assert_not_nil context_data_source.data_source
		} } }
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_context_data_source

end
