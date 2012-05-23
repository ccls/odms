require 'test_helper'

class OdmsExceptionExceptableTest < ActiveSupport::TestCase

	assert_should_create_default_object

	test "explicit Factory odms_exception_exceptable test" do
		assert_difference('BirthDatumUpdate.count',1) {		#	test default contextable
		assert_difference('OdmsException.count',1) {
		assert_difference('OdmsExceptionExceptable.count',1) {
			odms_exception_exceptable = Factory(:odms_exception_exceptable)
			assert_not_nil odms_exception_exceptable.odms_exception
			assert_not_nil odms_exception_exceptable.exceptable	#	polymorphic
			assert odms_exception_exceptable.exceptable.is_a?(BirthDatumUpdate)
		} } }
	end
protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_odms_exception_exceptable

end
