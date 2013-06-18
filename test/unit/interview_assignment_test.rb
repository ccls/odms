require 'test_helper'

class InterviewAssignmentTest < ActiveSupport::TestCase

	assert_should_belong_to(:study_subject)
	assert_should_require_attribute_length( :status,
		:maximum => 250 )
	assert_should_require_attribute_length( :notes_for_interviewer,
		:maximum => 65000 )
	assert_requires_complete_date( :sent_on, :returned_on )

#	test "should fail" do
#		flunk
#	end
#
#	test "should error" do
#		raise
#	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_interview_assignment

end
