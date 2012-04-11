require 'test_helper'

class StudySubjectGuardianRelationshipTest < ActiveSupport::TestCase

	assert_should_belong_to( :guardian_relationship, 
		:model      => 'StudySubject',
		:class_name => 'SubjectRelationship' )

end
