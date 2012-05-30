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

	test "should belong to exceptable" do
		odms_exception = Factory(:odms_exception)
		assert_not_nil odms_exception.exceptable
		assert odms_exception.exceptable.is_a?(BirthDatumUpdate)
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_odms_exception

end
