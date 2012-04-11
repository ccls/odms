require 'test_helper'

class StudySubjectInterviewsTest < ActiveSupport::TestCase

	assert_should_have_many( :interviews, :model => 'StudySubject' )

	test "should NOT destroy interviews with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Interview.count',1) {
			@study_subject = Factory(:interview).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Interview.count',0) {
			@study_subject.destroy
		} }
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
