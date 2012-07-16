require 'test_helper'

class PersonTest < ActiveSupport::TestCase

	assert_should_create_default_object

	attributes = %w( last_name position first_name
		honorific organization_id person_type_id email )
	required   = %w( last_name )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes )
	assert_should_not_protect( attributes )

	assert_should_act_as_list
	assert_should_have_many( :organizations )

#	TODO assert_should_have_many( :interviews, :foreign_key => :interviewer_id )

	assert_should_require_attribute_length( 
		:first_name, :last_name, :honorific, :email,
			:maximum => 250 )

	test "person factory should create person" do
		assert_difference('Person.count',1) {
			person = Factory(:person)
			assert_match /LastName\d*/, person.last_name
		}
	end

	test "should return full_name as to_s" do
		person = create_person
		assert_equal person.full_name, "#{person}"
	end

	test "should find random" do
		person = Person.random()
		assert person.is_a?(Person)
	end

	test "should return nil on random when no records" do
		Person.stubs(:count).returns(0)
		person = Person.random()
		assert_nil person
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_person

end
