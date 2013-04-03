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
			interview = FactoryGirl.create(:interview)
		}
	end

	test "interview factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			interview = FactoryGirl.create(:interview)
			assert_not_nil interview.study_subject
		}
	end

	test "should NOT require address" do
		interview = Interview.new(:address => nil)
		interview.valid?
		assert !interview.errors.include?(:address)
		assert !interview.errors.include?(:address_id)
	end

	test "should require valid address if given" do
		interview = Interview.new(:address_id => 0)
		assert !interview.valid?
		assert  interview.errors.include?(:address)
	end

	test "should NOT require interviewer" do
		interview = Interview.new(:interviewer => nil)
		interview.valid?
		assert !interview.errors.include?(:interviewer)
		assert !interview.errors.include?(:interviewer_id)
	end

	test "should require valid interviewer if given" do
		interview = Interview.new(:interviewer_id => 0)
		assert !interview.valid?
		assert  interview.errors.include?(:interviewer)
	end

	test "should NOT require instrument_version" do
		interview = Interview.new(:instrument_version => nil)
		interview.valid?
		assert !interview.errors.include?(:instrument_version_id)
		assert !interview.errors.include?(:instrument_version)
	end

	test "should require valid instrument_version if given" do
		interview = Interview.new(:instrument_version_id => 0)
		assert !interview.valid?
		assert  interview.errors.include?(:instrument_version)
	end

	test "should NOT require interview_method" do
		interview = Interview.new(:interview_method => nil)
		interview.valid?
		assert !interview.errors.include?(:interview_method_id)
		assert !interview.errors.include?(:interview_method)
	end

	test "should require valid interview_method if given" do
		interview = Interview.new(:interview_method_id => 0)
		assert !interview.valid?
		assert  interview.errors.include?(:interview_method)
	end

	test "should NOT require language" do
		interview = Interview.new(:language => nil)
		interview.valid?
		assert !interview.errors.include?(:language_id)
		assert !interview.errors.include?(:language)
	end

	test "should require valid language if given" do
		interview = Interview.new(:language_id => 0)
		assert !interview.valid?
		assert  interview.errors.include?(:language)
	end

	test "should NOT require study_subject" do
		interview = Interview.new(:study_subject => nil)
		interview.valid?
		assert !interview.errors.include?(:study_subject_id)
		assert !interview.errors.include?(:study_subject)
	end

	test "should require valid study_subject if given" do
		#	study_subject_id is protected so must use block
		interview = Interview.new{|i| i.study_subject_id = 0}
		assert !interview.valid?
		assert  interview.errors.include?(:study_subject)
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
			:subject_relationship => FactoryGirl.create(:subject_relationship),
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
