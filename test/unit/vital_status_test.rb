require 'test_helper'

class VitalStatusTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
#	assert_should_have_many( :study_subjects )
	assert_should_not_require_attributes( :position )
	assert_should_require_attributes( :code )
	assert_should_require_unique_attributes( :code )

	test "vital_status factory should create vital status" do
		assert_difference('VitalStatus.count',1) {
			vital_status = FactoryGirl.create(:vital_status)
			assert_match     /\d*/, vital_status.code.to_s
			assert_match  /key\d*/, vital_status.key
			assert_match /Desc\d*/, vital_status.description
		}
	end

	test "should return description as to_s" do
		vital_status = VitalStatus.new(:description => 'testing')
		assert_equal vital_status.description, 'testing'
		assert_equal vital_status.description, "#{vital_status}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_vital_status

end
