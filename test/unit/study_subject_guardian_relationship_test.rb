require 'test_helper'

class StudySubjectGuardianRelationshipTest < ActiveSupport::TestCase

	assert_should_belong_to( :guardian_relationship, 
		:model      => 'StudySubject',
		:class_name => 'SubjectRelationship' )

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
