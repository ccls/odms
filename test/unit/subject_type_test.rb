require 'test_helper'

class SubjectTypeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
#	assert_should_have_many(:study_subjects)
	assert_should_not_require_attributes( :position, :related_case_control_type )

	test "subject_type factory should create subject type" do
		assert_difference('SubjectType.count',1) {
			subject_type = FactoryGirl.create(:subject_type)
			assert_match /Key\d*/, subject_type.key
			assert_match /Desc\d*/, subject_type.description
		}
	end

	test "should return description as name" do
		subject_type = SubjectType.new(:description => 'testing')
		assert_equal subject_type.description, 'testing'
		assert_equal subject_type.description,
			subject_type.name
	end

	test "should return description as to_s" do
		subject_type = SubjectType.new(:description => 'testing')
		assert_equal subject_type.description, 'testing'
		assert_equal subject_type.description,
			"#{subject_type}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_subject_type

end
