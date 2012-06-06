require 'test_helper'

class ProjectOutcomeTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object
	assert_should_act_as_list
	assert_should_not_require_attributes( :position, :project_id )
	assert_should_have_many( :enrollments )

	test "project_outcome factory should create project outcome" do
		assert_difference('ProjectOutcome.count',1) {
			project_outcome = Factory(:project_outcome)
			assert_match /Key\d*/, project_outcome.key
			assert_match /Desc\d*/, project_outcome.description
		}
	end

	test "should return description as to_s" do
		project_outcome = ProjectOutcome.new(:description => 'testing')
		assert_equal project_outcome.description, 'testing'
		assert_equal project_outcome.description,
			"#{project_outcome}"
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_project_outcome

end
