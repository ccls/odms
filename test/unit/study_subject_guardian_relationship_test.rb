require 'test_helper'

class StudySubjectGuardianRelationshipTest < ActiveSupport::TestCase

	assert_should_belong_to( :guardian_relationship, 
		:model      => 'StudySubject',
		:class_name => 'SubjectRelationship' )

	test "should require other_guardian_relationship if " <<
			"guardian_relationship == other" do
		assert_difference( "StudySubject.count", 0 ) do
			study_subject = create_study_subject(
				:guardian_relationship => SubjectRelationship['other'] )
			assert study_subject.errors.include?(:other_guardian_relationship)
			#	NOTE custom error message
			assert study_subject.errors.matching?(:other_guardian_relationship,
				"You must specify a relationship with 'other relationship' is selected")
		end
	end

	test "should require other_guardian_relationship with custom message" do
		assert_difference( "StudySubject.count", 0 ) do
			study_subject = create_study_subject(
				:guardian_relationship => SubjectRelationship['other'] )
			assert study_subject.errors.matching?(:other_guardian_relationship,
				"You must specify a relationship with 'other relationship' is selected")
			#	NOTE custom error message WITHOUT attribute name
			assert_no_match /Other guardian relationship/, 
				study_subject.errors.full_messages.to_sentence
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
