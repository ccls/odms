require 'test_helper'

class DiagnosisTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object

#	attributes = %w( code position )
#	required   = %w( code )
#	unique     = %w( code )
	attributes = %w( position )
#	assert_should_require( required )
#	assert_should_require_unique( unique )
	assert_should_not_require( attributes )	#- required )
	assert_should_not_require_unique( attributes )	#- unique )
	assert_should_not_protect( attributes )

	assert_should_act_as_list
	#	NOTE	code is an integer for diagnosis (so key is used)

	test "explicit Factory diagnosis test" do
		assert_difference('Diagnosis.count',1) {
			diagnosis = Factory(:diagnosis)
			assert_match /Key\d*/,  diagnosis.key
#			assert_match /\d*/,     diagnosis.code.to_s
			assert_match /Desc\d*/, diagnosis.description
		}
	end

	test "should return description as to_s" do
		diagnosis = Diagnosis.new(:description => 'testing')
		assert_equal diagnosis.description, 'testing'
		assert_equal diagnosis.description, "#{diagnosis}"
	end

	test "Diagnosis['other'] should return true for is_other?" do
		diagnosis = Diagnosis['other']
		assert diagnosis.is_other?
	end

	test "Diagnosis['ALL'] should return false for is_other?" do
		diagnosis = Diagnosis['ALL']
		assert !diagnosis.is_other?
	end

	test "Diagnosis['AML'] should return false for is_other?" do
		diagnosis = Diagnosis['AML']
		assert !diagnosis.is_other?
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_diagnosis

end
