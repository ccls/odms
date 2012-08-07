require 'test_helper'

class ContextContextableTest < ActiveSupport::TestCase

	assert_should_create_default_object
#	assert_should_initially_belong_to( :context, :contextable )

	test "context_contextable factory should create context contextable" do
		assert_difference('ContextContextable.count',1) {
			context_contextable = Factory(:context_contextable)
		}
	end

	test "context_contextable factory should create context" do
		assert_difference('Context.count',1) {
			context_contextable = Factory(:context_contextable)
			assert_not_nil context_contextable.context
		}
	end

	test "context_contextable factory should create default contextable" do
		assert_difference('DataSource.count',1) {		#	test default contextable
			context_contextable = Factory(:context_contextable)
			assert_not_nil context_contextable.contextable	#	polymorphic
			assert context_contextable.contextable.is_a?(DataSource)
		}
	end

	test "context_contextable factory should create Unit contextable" do
		assert_difference('Unit.count',1) {		#	test default contextable
			context_contextable = Factory(:context_contextable,
				:contextable => Factory(:unit))
			assert_not_nil context_contextable.contextable	#	polymorphic
			assert context_contextable.contextable.is_a?(Unit)
		}
	end

#	test "should require unique context_id, contextable_id and contextable_type" do
#	TODO (index in db, but validation not in model)
#	remove this index?? Let's see how this goes
#pending	
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_context_contextable

end
