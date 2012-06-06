require 'test_helper'

class InterviewTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to(:study_subject)
	assert_should_belong_to( :address, :instrument_version,
		:interview_method, :language, :subject_relationship )
	assert_should_belong_to( :interviewer, :class_name => 'Person')


	attributes = %w( address_id began_at consent_read_over_phone 
		consent_reviewed_with_respondent ended_at instrument_version_id 
		interview_method_id interviewer_id intro_letter_sent_on language_id 
		respondent_requested_new_consent study_subject_id )
	protected_attributes = %w( study_subject_id study_subject )
	assert_should_not_require( attributes )
	assert_should_not_require_unique( attributes )
	assert_should_protect( protected_attributes )
	assert_should_not_protect( attributes - protected_attributes )

	assert_should_require_attribute_length( 
		:other_subject_relationship, 
		:respondent_first_name,
		:respondent_last_name, 
			:maximum => 250 )

	assert_requires_complete_date( :began_at, :ended_at, :intro_letter_sent_on )

	test "interview factory should create interview" do
		assert_difference('Interview.count',1) {
			interview = Factory(:interview)
		}
	end

	test "interview factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			interview = Factory(:interview)
			assert_not_nil interview.study_subject
		}
	end

#	test "should create intro letter operational event " <<
#			"when intro_letter_sent_on set" do
#		study_subject = create_hx_study_subject
#		assert_difference( "OperationalEvent.count", 1 ) {
#		assert_difference( "Interview.count", 1 ) {
#			@interview = create_interview( :study_subject => study_subject,
#				:intro_letter_sent_on => Date.yesterday ).reload
#		} }
#		oe = study_subject.operational_events.where(
#			:project_id => Project['HomeExposures'].id).first
#		assert_equal OperationalEventType['intro'],   oe.operational_event_type
#		assert_equal @interview.intro_letter_sent_on, oe.occurred_on
#	end
#
#	test "should update intro letter operational event " <<
#			"when intro_letter_sent_on updated" do
#		study_subject = create_hx_study_subject
#		interview = create_interview(
#			:study_subject => study_subject,
#			:intro_letter_sent_on => Date.yesterday )
#		assert_difference( "OperationalEvent.count", 0 ) {
#		assert_difference( "Interview.count", 0 ) {
#			interview.update_attributes(:intro_letter_sent_on => Date.today )
#		} }
#		assert_equal interview.intro_letter_sent_on, Date.today
#		oe = study_subject.operational_events.where(
#			:project_id => Project['HomeExposures'].id).first
#		assert_equal interview.intro_letter_sent_on, oe.occurred_on
#	end

#	TODO I think that these should require valid
#		They shouldn't require the _id, but if given the association should be valid.

	test "should NOT require valid address_id" do
		interview = Interview.new(:address_id => 0)
		interview.valid?
		assert !interview.errors.include?(:address)
	end

	test "should NOT require valid interviewer_id" do
		interview = Interview.new(:interviewer_id => 0)
		interview.valid?
		assert !interview.errors.include?(:interviewer)
	end

	test "should NOT require valid instrument_version_id" do
		interview = Interview.new(:instrument_version_id => 0)
		interview.valid?
		assert !interview.errors.include?(:instrument_version_id)
	end

	test "should NOT require valid interview_method_id" do
		interview = Interview.new(:interview_method_id => 0)
		interview.valid?
		assert !interview.errors.include?(:interview_method_id)
	end

	test "should NOT require valid language_id" do
		interview = Interview.new(:language_id => 0)
		interview.valid?
		assert !interview.errors.include?(:language_id)
	end

	test "should NOT require valid study_subject_id" do
		interview = Interview.new(:study_subject_id => 0)
		interview.valid?
		assert !interview.errors.include?(:study_subject_id)
	end

	test "should return join of respondent's name" do
		interview = Interview.new(
			:respondent_first_name => "Santa",
			:respondent_last_name => "Claus" )
		assert_equal 'Santa Claus', interview.respondent_full_name
	end

	test "should require other_subject_relationship if " <<
			"subject_relationship == other" do
		interview = Interview.new(
			:subject_relationship => SubjectRelationship['other'] )
		assert !interview.valid?
		assert interview.errors.include?(:other_subject_relationship)
	end

	test "should NOT ALLOW other_subject_relationship if " <<
			"subject_relationship is blank" do
		interview = Interview.new(
			:subject_relationship_id => '',
			:other_subject_relationship => 'asdfasdf' )
		assert !interview.valid?
		assert interview.errors.include?(:other_subject_relationship)
	end

	test "should ALLOW other_subject_relationship if " <<
			"subject_relationship != other" do
		interview = Interview.new(
			:subject_relationship => Factory(:subject_relationship),
			:other_subject_relationship => 'asdfasdf' )
		interview.valid?
		assert !interview.errors.include?(:other_subject_relationship)
	end

	test "should require other_subject_relationship with custom message" do
		interview = Interview.new(
			:subject_relationship => SubjectRelationship['other'] )
		assert !interview.valid?
		assert  interview.errors.include?(:other_subject_relationship)
		assert_match /You must specify a relationship with 'other relationship' is selected/, 
			interview.errors.full_messages.to_sentence
		assert_no_match /Other subject relationship/, 
			interview.errors.full_messages.to_sentence
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_interview

end
