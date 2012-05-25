require 'test_helper'

class OdmsExceptionTest < ActiveSupport::TestCase

	assert_should_create_default_object

	test "explicit Factory odms_exception test" do
		assert_difference('OdmsException.count',1) {
			odms_exception = Factory(:odms_exception)
			assert_nil odms_exception.name
			assert_nil odms_exception.description
		}
	end

	test "should return name:description as to_s" do
		odms_exception = OdmsException.new(
			:name => 'mynameis',
			:description => 'testing')
		assert_equal odms_exception.name, 'mynameis'
		assert_equal odms_exception.description, 'testing'
		assert_equal odms_exception.to_s,
			"#{odms_exception.name}:#{odms_exception.description}"
	end

	test "should have many odms_exception_exceptable" do
		odms_exception = Factory(:odms_exception)
		assert odms_exception.odms_exception_exceptables.empty?
	end

	test "should have many exceptables through odms_exception_exceptable (sort of)" do
		#	apparently can't have many through a polymorphic relationship
		#	so this is really just a method that mimics it.
		odms_exception = Factory(:odms_exception)
		assert odms_exception.exceptables.empty?
		Factory(:odms_exception_exceptable, :odms_exception => odms_exception )
		assert !odms_exception.reload.exceptables.empty?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_odms_exception

end
