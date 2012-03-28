require 'test_helper'

class DocumentVersionTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_initially_belong_to(:document_type)
	assert_should_belong_to( :language )

	attributes = %w( position title description indicator
		language_id began_use_on ended_use_on )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :title, :description, :indicator,
		:maximum => 250 )
	assert_requires_complete_date( :began_use_on, :ended_use_on )

	test "explicit Factory document_version test" do
		assert_difference('DocumentType.count',1) {
		assert_difference('DocumentVersion.count',1) {
			document_version = Factory(:document_version)
			assert_match /Title\d*/,  document_version.title
			assert_not_nil document_version.document_type
		} }
	end

	test "should require document_type" do
		assert_difference( "DocumentVersion.count", 0 ) do
			document_version = create_document_version( :document_type => nil)
			assert !document_version.errors.include?(:document_type)
			assert  document_version.errors.matching?(:document_type_id,"can't be blank")
		end
	end

	test "should require valid document_type" do
		assert_difference( "DocumentVersion.count", 0 ) do
			document_version = create_document_version( :document_type_id => 0)
			assert !document_version.errors.include?(:document_type_id)
			assert  document_version.errors.matching?(:document_type,"can't be blank")
		end
	end

	test "should only return document type id == 1 for type1" do
		objects = DocumentVersion.type1
		assert_not_nil objects
		objects.each do |o|
			assert_equal 1, o.document_type_id
		end
	end

	test "should return title as to_s" do
		document_version = create_document_version
		assert_equal document_version.title, "#{document_version}"
	end

	test "should have many consented enrollments" do
		document_version = create_document_version
		assert_equal 0, document_version.enrollments.length
		document_version.enrollments << Factory(:consented_enrollment)
		assert_equal 1, document_version.reload.enrollments.length
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_document_version

end
