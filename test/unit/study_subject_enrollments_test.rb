require 'test_helper'

class StudySubjectEnrollmentsTest < ActiveSupport::TestCase

	test "should create study_subject and accept_nested_attributes_for enrollments" do
		assert_difference( 'Enrollment.count', 2) {	#	ccls enrollment is auto-created, so 2
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject(
				:enrollments_attributes => [FactoryGirl.attributes_for(:enrollment,
					:project_id => Project['non-specific'].id)])
			assert !study_subject.new_record?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should NOT destroy enrollments with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Enrollment.count',2) {	#	due to the callback creation of ccls enrollment
			@study_subject = FactoryGirl.create(:enrollment).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Enrollment.count',0) {
			@study_subject.destroy
		} }
	end

	test "should return nil hx_enrollment if not enrolled" do
		study_subject = create_study_subject
		assert_nil study_subject.enrollments.find_by_project_id(
			Project['HomeExposures'].id)
	end

	test "should return valid hx_enrollment if enrolled" do
		study_subject = create_study_subject
		hxe = FactoryGirl.create(:enrollment,
			:study_subject => study_subject,
			:project => Project['HomeExposures']
		)
		assert_not_nil study_subject.enrollments.find_by_project_id(
			Project['HomeExposures'].id)
	end

	test "should create ccls project enrollment on creation" do
		study_subject = nil
		assert_difference('Project.count',0) {	#	make sure it didn't create id
		assert_difference('Enrollment.count',1) {
		assert_difference('StudySubject.count',1) {
			study_subject = create_study_subject
		} } }
		assert_not_nil study_subject.enrollments.find_by_project_id(Project['ccls'].id)
	end

	test "should only create 1 ccls project enrollment on creation if given one" do
		study_subject = nil
		assert_difference('Project.count',0) {	#	make sure it didn't create id
		assert_difference('Enrollment.count',1) {
		assert_difference('StudySubject.count',1) {
			study_subject = create_study_subject(:enrollments_attributes => [
				{ :project_id => Project['ccls'].id }
			])
		} } }
		assert_not_nil study_subject.enrollments.find_by_project_id(Project['ccls'].id)
	end

	test "should return projects not enrolled by given study_subject" do
		study_subject = create_study_subject
		unenrolled = study_subject.unenrolled_projects
		assert_not_nil unenrolled

#		assert unenrolled.is_a?(Array)
		assert unenrolled.is_a?(ActiveRecord::Relation)
		assert unenrolled.all.is_a?(Array)

		assert_equal 10, Project.count
		#	due to the auto-enrollment in ccls, there are only 9 now
		assert_equal 9, unenrolled.length
	end

end
