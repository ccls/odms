require 'test_helper'

class ContextContextableTest < ActiveSupport::TestCase

	assert_should_create_default_object
#	assert_should_initially_belong_to( :context, :contextable )

	test "explicit Factory context_contextable test" do
		assert_difference('DataSource.count',1) {		#	test default contextable
		assert_difference('Context.count',1) {
		assert_difference('ContextContextable.count',1) {
			context_contextable = Factory(:context_contextable)
			assert_not_nil context_contextable.context
			assert_not_nil context_contextable.contextable	#	polymorphic
			assert context_contextable.contextable.is_a?(DataSource)
		} } }
	end

	test "explicit Factory context_contextable test with Unit" do
		assert_difference('Unit.count',1) {		#	test default contextable
		assert_difference('Context.count',1) {
		assert_difference('ContextContextable.count',1) {
#
#	contextable could be any model, Unit for example.
#
			context_contextable = Factory(:context_contextable,
				:contextable => Factory(:unit))
			assert_not_nil context_contextable.context
			assert_not_nil context_contextable.contextable	#	polymorphic
			assert context_contextable.contextable.is_a?(Unit)
		} } }
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_context_contextable

end
