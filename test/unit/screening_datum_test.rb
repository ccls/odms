require 'test_helper'

class ScreeningDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )
	assert_should_belong_to( :screening_datum_update )

	test "screening_datum factory should create screening datum" do
		screening_datum = Factory(:screening_datum)
		assert !screening_datum.new_record?
	end

	test "screening_datum factory should have dob" do
		screening_datum = Factory(:screening_datum)
		assert_not_nil screening_datum.dob
	end

	test "screening_datum factory should have sex" do
		screening_datum = Factory(:screening_datum)
		assert_not_nil screening_datum.sex
	end

	test "screening_datum factory should not have first name" do
		screening_datum = Factory(:screening_datum)
		assert_nil screening_datum.first_name
	end

	test "screening_datum factory should not have last name" do
		screening_datum = Factory(:screening_datum)
		assert_nil screening_datum.last_name
	end

#	test "should return join of screening_datum's name" do
#		screening_datum = ScreeningDatum.new(
#			:first_name  => "John",
#			:middle_name => "Michael",
#			:last_name   => "Smith" )
#		assert_equal 'John Michael Smith', screening_datum.full_name 
#	end
#
#	test "should return join of screening_datum's name with blank middle name" do
#		screening_datum = ScreeningDatum.new(
#			:first_name  => "John",
#			:middle_name => "",
#			:last_name   => "Smith" )
#		assert_equal 'John Smith', screening_datum.full_name 
#	end
#
#	test "should return join of screening_datum's mother's name" do
#		screening_datum = ScreeningDatum.new(
#			:mother_first_name  => "Jane",
#			:mother_middle_name => "Anne",
#			:mother_maiden_name => "Smith" )
#		assert_equal 'Jane Anne Smith', screening_datum.mother_full_name 
#	end
#
#	test "should return join of screening_datum's mother's name with blank mother's middle name" do
#		screening_datum = ScreeningDatum.new(
#			:mother_first_name  => "Jane",
#			:mother_middle_name => "",
#			:mother_maiden_name => "Smith" )
#		assert_equal 'Jane Smith', screening_datum.mother_full_name 
#	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_screening_datum

end
