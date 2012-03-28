require 'test_helper'

class DocumentTypeTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_behave_like_a_hash
	assert_should_have_many(:document_versions)

	attributes = %w( title position )
	required   = %w( title )
#	unique     = %w( )
	assert_should_require( required )
#	assert_should_require_unique( unique )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes )	#- unique )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :title, :maximum => 250 )

	test "explicit Factory document_type test" do
		assert_difference('DocumentType.count',1) {
			document_type = Factory(:document_type)
			assert_match /Key\d*/,   document_type.key
			assert_match /Title\d*/, document_type.title
			assert_match /Desc\d*/,  document_type.description
		}
	end

	test "should return title as to_s" do
		document_type = create_document_type
		assert_equal document_type.title, "#{document_type}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_document_type

end
