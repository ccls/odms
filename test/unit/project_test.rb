require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

	assert_should_behave_like_a_hash

	assert_should_create_default_object

	assert_should_have_many( :instrument_types, :enrollments, :instruments, 
		:samples, :operational_events )
#		:samples, :gift_cards, :operational_events )

	attributes = %w( position began_on ended_on eligibility_criteria label )
	required = %w( label )
	unique = %w( label )
	
	assert_should_require( required )
	assert_should_require_unique( unique )
	assert_should_not_require( attributes - required )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes )

	assert_should_require_attribute_length( :eligibility_criteria, :maximum => 65000 )
	assert_should_act_as_list

	assert_requires_complete_date( :began_on, :ended_on )

	test "project factory should create project" do
		assert_difference('Project.count',1) {
			project = FactoryGirl.create(:project)
			assert_match /Key\d*/, project.key
			assert_match /Desc\d*/, project.description
		}
	end

	test "should return description as to_s" do
		project = Project.new(:description => 'testing')
		assert_equal project.description, 'testing'
		assert_equal project.description, "#{project}"
	end

	test "should have many study_subjects through enrollments" do
		project = create_project
		assert_equal 0, project.study_subjects.length
		FactoryGirl.create(:enrollment, :project_id => project.id)
		assert_equal 1, project.reload.study_subjects.length
		FactoryGirl.create(:enrollment, :project_id => project.id)
		assert_equal 2, project.reload.study_subjects.length
	end

#	#	this method seems like it would be better suited to 
#	#	be in the StudySubject model rather than Project
#	test "should return projects not enrolled by given study_subject" do
#		study_subject = create_study_subject
#		unenrolled = Project.unenrolled_projects(study_subject)
#		assert_not_nil unenrolled
#		assert unenrolled.all.is_a?(Array)
#		assert_equal 10, Project.count
#		#	due to the auto-enrollment in ccls, there are only 9 now
#		assert_equal 9, unenrolled.length
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_project

end
