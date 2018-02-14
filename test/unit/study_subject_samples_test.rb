require 'test_helper'

class StudySubjectSamplesTest < ActiveSupport::TestCase

	assert_should_have_many( :samples, :model => 'StudySubject' )

	test "should NOT destroy samples with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Sample.count',1) {
			@study_subject = FactoryBot.create(:sample).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Sample.count',0) {
			@study_subject.destroy
		} }
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
