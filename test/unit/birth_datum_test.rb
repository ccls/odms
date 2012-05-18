require 'test_helper'

class BirthDatumTest < ActiveSupport::TestCase

	assert_should_create_default_object

	assert_should_belong_to( :study_subject )
	assert_should_belong_to( :birth_datum_update )

#	needs special test as is created in an after_create
#	assert_should_have_one( :candidate_control )


	test "explicit Factory birth_datum test" do
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:birth_datum)
			assert_equal 'First', birth_datum.first_name
			assert_equal 'Last',  birth_datum.last_name
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_nil     birth_datum.case_control_flag
		} }
	end

	test "explicit Factory case_birth_datum test" do
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:case_birth_datum)
			assert_equal 'First', birth_datum.first_name
			assert_equal 'Last',  birth_datum.last_name
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'case', birth_datum.case_control_flag
		} }
	end

	test "explicit Factory control_birth_datum test" do
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',1) {
			birth_datum = Factory(:control_birth_datum)
			assert_equal 'First', birth_datum.first_name
			assert_equal 'Last',  birth_datum.last_name
			assert_not_nil birth_datum.dob
			assert_not_nil birth_datum.sex
			assert_equal  'control', birth_datum.case_control_flag
		} }
	end

	test "should return join of birth_datum's name" do
		birth_datum = BirthDatum.new(
			:first_name  => "John",
			:middle_name => "Michael",
			:last_name   => "Smith" )
		assert_equal 'John Michael Smith', birth_datum.full_name 
	end

	test "should return join of birth_datum's name with blank middle name" do
		birth_datum = BirthDatum.new(
			:first_name  => "John",
			:middle_name => "",
			:last_name   => "Smith" )
		assert_equal 'John Smith', birth_datum.full_name 
	end

	test "should return join of birth_datum's mother's name" do
		birth_datum = BirthDatum.new(
			:mother_first_name  => "Jane",
			:mother_middle_name => "Anne",
			:mother_maiden_name => "Smith" )
		assert_equal 'Jane Anne Smith', birth_datum.mother_full_name 
	end

	test "should return join of birth_datum's mother's name with blank mother's middle name" do
		birth_datum = BirthDatum.new(
			:mother_first_name  => "Jane",
			:mother_middle_name => "",
			:mother_maiden_name => "Smith" )
		assert_equal 'Jane Smith', birth_datum.mother_full_name 
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_birth_datum

end
