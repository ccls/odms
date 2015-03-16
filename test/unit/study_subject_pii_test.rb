require 'test_helper'

#	This is just a collection of pii related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectPiiTest < ActiveSupport::TestCase

	assert_should_require( :dob, :model => 'StudySubject' )
	assert_should_not_require( :birth_city, 
		:birth_state, :birth_country, :model => 'StudySubject' )
	assert_should_not_require_unique( :dob, :birth_city, 
		:birth_state, :birth_country, :model => 'StudySubject' )
	assert_should_not_protect( :dob, :birth_city,
		:birth_state, :birth_country, :model => 'StudySubject' )
	assert_should_require_attribute_length(
		:birth_city, 
		:birth_state, :birth_country, 
		:model => 'StudySubject', :maximum => 250 )
	assert_requires_complete_date( :dob, :model => 'StudySubject' )
	assert_requires_past_date( :dob, :model => 'StudySubject' )

	test "should not require dob on creation for mother" do
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(
				:subject_type => 'Mother',
				:dob => nil )
		}
		assert_nil @study_subject.reload.dob
	end

	test "should not require dob on update for mother" do
		#	flag not necessary as study_subject.subject_type exists
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_type => 'Mother' )
		}
		assert_not_nil @study_subject.reload.dob
		@study_subject.update_attributes(:dob => nil)
		assert_nil @study_subject.reload.dob
	end

	test "should return dob as a date NOT time" do
		study_subject = create_study_subject(:dob => (Time.now - 5.days) )
		assert_not_nil study_subject.dob
		assert_changes("StudySubject.find(#{study_subject.id}).dob") {
			study_subject.update_attributes(:dob => (Time.now - 4.days) )
		}
		assert study_subject.persisted?
		assert_not_nil study_subject.dob
#		#	Is this really required anymore?
#		#	Why exactly did it matter in the beginning?
#		#	Why exactly does it matter anymore?
#
#		puts study_subject.dob
#		puts study_subject.dob.class
#
#		assert study_subject.dob.is_a?(Time)
#		#	will actually keep as time if given time until reloaded
#		rails 4 works by default
#
		assert study_subject.dob.is_a?(Date)
		assert study_subject.reload.dob.is_a?(Date)
	end

	test "should parse a properly formatted date for dob" do
		assert_difference( "StudySubject.count", 1 ) do
			study_subject = create_study_subject(
				:dob => Date.parse("January 1 2001") )
			assert study_subject.persisted?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		end
	end

	test "should require dob with custom message" do
		#	NOTE custom message
		assert_difference( "StudySubject.count", 0 ) do
			study_subject = create_study_subject( :dob => nil )
			assert study_subject.errors.matching?(:dob,"can't be blank")
			assert_match /Date of Birth can't be blank/, 
				study_subject.errors.full_messages.to_sentence
			assert_no_match /DOB/i, 
				study_subject.errors.full_messages.to_sentence
		end
	end

	test "should not require dob if subject is mother" do
		assert_difference('StudySubject.count',1) do
			study_subject = create_mother_study_subject( :dob => nil )
		end
	end

	test "should require dob if subject is not mother" do
		assert_difference('StudySubject.count',0) do
			study_subject = create_study_subject( :dob => nil )
		end
	end

	test "should require birth_city if birth_country is 'United States'" do
		assert_difference( "StudySubject.count", 0 ) do
			study_subject = create_study_subject( :birth_country => 'United States' )
			assert study_subject.errors.matching?(:birth_city,"can't be blank")
		end
	end

	test "should require birth_state if birth_country is 'United States'" do
		assert_difference( "StudySubject.count", 0 ) do
			study_subject = create_study_subject( :birth_country => 'United States' )
			assert study_subject.errors.matching?(:birth_state,"can't be blank")
		end
	end

	test "should set birth_year to dob.year on create" do
		study_subject = Factory(:study_subject)
		assert_not_nil study_subject.dob
		assert_not_nil study_subject.birth_year
		assert_equal study_subject.birth_year, study_subject.dob.year.to_s
		study_subject.reload
		assert_equal study_subject.birth_year, study_subject.dob.year.to_s
	end

	test "should set birth_year to dob.year on update" do
		study_subject = Factory(:study_subject, :dob => '12/31/2000').reload
		assert_equal '2000', study_subject.birth_year
		assert_equal '2000', study_subject.reload.birth_year
		study_subject.update_attribute(:dob, '1/1/2013')
		assert_equal '2013', study_subject.birth_year
		assert_equal '2013', study_subject.reload.birth_year
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
