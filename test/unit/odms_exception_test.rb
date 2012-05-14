require 'test_helper'

class OdmsExceptionTest < ActiveSupport::TestCase

	assert_should_create_default_object

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_odms_exception

end
