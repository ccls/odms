require 'test_helper'

class OdmsExceptionExceptableTest < ActiveSupport::TestCase

	assert_should_create_default_object

	test "explicit Factory odms_exception_exceptable test" do
		assert_difference('BirthDatum.count',1) {		#	test default contextable
		assert_difference('OdmsException.count',1) {
		assert_difference('OdmsExceptionExceptable.count',1) {
			odms_exception_exceptable = Factory(:odms_exception_exceptable)
			assert_not_nil odms_exception_exceptable.odms_exception
			assert_not_nil odms_exception_exceptable.exceptable	#	polymorphic
			assert odms_exception_exceptable.exceptable.is_a?(BirthDatum)
		} } }
	end
protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_odms_exception_exceptable

end
__END__


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

#	test "should require unique context_id, contextable_id and contextable_type" do
#	TODO (index in db, but validation not in model)
#	remove this index?? Let's see how this goes
#pending	
#	end
