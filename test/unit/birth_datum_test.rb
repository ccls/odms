require 'test_helper'

class BirthDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_birth_datum

end
