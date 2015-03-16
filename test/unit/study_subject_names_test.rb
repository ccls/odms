require 'test_helper'

class StudySubjectNamesTest < ActiveSupport::TestCase

	assert_should_require_attribute_length( 
		:first_name, :middle_name, :maiden_name, :last_name,
		:mother_first_name, :mother_middle_name, :mother_maiden_name, :mother_last_name,
		:father_first_name, :father_middle_name, :father_last_name,
		:guardian_first_name, :guardian_middle_name, :guardian_last_name,
			:model => 'StudySubject', :maximum => 250 )

	attributes = %w( 
		first_name middle_name last_name maiden_name
		father_first_name father_middle_name father_last_name
		guardian_first_name guardian_last_name guardian_middle_name 
		mother_first_name mother_middle_name mother_last_name mother_maiden_name 
	)
	assert_should_not_require( attributes, :model => 'StudySubject' )
	assert_should_not_require_unique( attributes, :model => 'StudySubject' )
	assert_should_not_protect( attributes, :model => 'StudySubject' )

	test "should return 'name not available' for study_subject without names" do
		study_subject = StudySubject.new
		assert_nil study_subject.first_name
		assert_nil study_subject.middle_name
		assert_nil study_subject.last_name
		assert_equal '[name not available]', study_subject.full_name
	end

	test "should return join of study_subject's initials" do
		study_subject = StudySubject.new(
			:first_name  => "John",
			:middle_name => "X",
			:last_name   => "Smith" )
		assert_not_nil study_subject.first_name
		assert_not_nil study_subject.middle_name
		assert_not_nil study_subject.last_name
		assert_equal 'JXS', study_subject.initials 
	end

	test "should return join of study_subject's initials without middle name" do
		study_subject = StudySubject.new(
			:first_name => "John",
			:last_name  => "Smith" )
		assert_not_nil study_subject.first_name
		assert_nil     study_subject.middle_name
		assert_not_nil study_subject.last_name
		assert_equal 'JS', study_subject.initials 
	end

	test "should return join of study_subject's initials with blank middle name" do
		study_subject = StudySubject.new(
			:first_name  => "John",
			:middle_name => "",
			:last_name   => "Smith" )
		assert_not_nil study_subject.first_name
		assert_not_nil study_subject.middle_name	#	NOT SAVED SO NOT NIL
		assert_not_nil study_subject.last_name
		assert_equal 'JS', study_subject.initials 
	end

	test "should return join of study_subject's initials with maiden name" do
		study_subject = StudySubject.new(
			:first_name  => "John",
			:middle_name => "Xavier",
			:maiden_name => "Hoopa",
			:last_name   => "Smith" )
		assert_not_nil study_subject.first_name
		assert_not_nil study_subject.middle_name
		assert_not_nil study_subject.maiden_name
		assert_not_nil study_subject.last_name
		assert_equal 'JXHS', study_subject.initials 
	end

	test "should return join of study_subject's name" do
		study_subject = StudySubject.new(
			:first_name  => "John",
			:middle_name => "Xavier",
			:last_name   => "Smith" )
		assert_not_nil study_subject.first_name
		assert_not_nil study_subject.middle_name
		assert_not_nil study_subject.last_name
		assert_equal 'John Xavier Smith', study_subject.full_name 
	end

	test "should return join of study_subject's name with maiden_name" do
		study_subject = StudySubject.new(
			:first_name  => "John",
			:middle_name => "Xavier",
			:maiden_name => "Hoopa",
			:last_name   => "Smith" )
		assert_not_nil study_subject.first_name
		assert_not_nil study_subject.middle_name
		assert_not_nil study_subject.maiden_name
		assert_not_nil study_subject.last_name
		assert_equal 'John Xavier Hoopa Smith', study_subject.full_name 
	end

	test "should return join of study_subject's name without middle name" do
		study_subject = StudySubject.new(
			:first_name => "John",
			:last_name  => "Smith" )
		assert_not_nil study_subject.first_name
		assert_nil     study_subject.middle_name	#	NOT SET SO NIL
		assert_not_nil study_subject.last_name
		assert_equal 'John Smith', study_subject.full_name 
	end

	test "should return join of study_subject's name with blank middle name" do
		study_subject = StudySubject.new(
			:first_name  => "John",
			:middle_name => "",
			:last_name   => "Smith" )
		assert_not_nil study_subject.first_name
		assert_not_nil study_subject.middle_name	#	NOT SAVED SO NOT NIL
		assert_not_nil study_subject.last_name
		assert_equal 'John Smith', study_subject.full_name 
	end

#	test "should return 'name not available' if study_subject's names are blank" do
#		study_subject = create_study_subject
#		assert_equal '[name not available]', study_subject.full_name 
#	end

	test "should return 'name not available' if study_subject's father's names are blank" do
		study_subject = create_study_subject
		study_subject = StudySubject.new
		assert_nil study_subject.father_first_name
		assert_nil study_subject.father_middle_name
		assert_nil study_subject.father_last_name
		assert_equal '[name not available]', study_subject.fathers_name
	end

	test "should return 'name not available' if study_subject's mother's names are blank" do
		study_subject = create_study_subject
		assert_nil study_subject.mother_first_name
		assert_nil study_subject.mother_middle_name
		assert_nil study_subject.mother_last_name
		assert_equal '[name not available]', study_subject.mothers_name
	end

	test "should return 'name not available' if study_subject's guardian's names are blank" do
		study_subject = create_study_subject
		assert_nil study_subject.guardian_first_name
		assert_nil study_subject.guardian_middle_name
		assert_nil study_subject.guardian_last_name
		assert_equal '[name not available]', study_subject.guardians_name
	end

	test "should return join of father's name" do
		study_subject = create_study_subject(
			:father_first_name  => "Santa",
			:father_middle_name => "X.",
			:father_last_name   => "Claus" )
		assert_not_nil study_subject.father_first_name
		assert_not_nil study_subject.father_middle_name
		assert_not_nil study_subject.father_last_name
		assert_equal 'Santa X. Claus', study_subject.fathers_name 
	end

	test "should return join of father's name without middle name" do
		study_subject = create_study_subject(
			:father_first_name => "Santa",
			:father_last_name  => "Claus" )
		assert_not_nil study_subject.father_first_name
		assert_nil     study_subject.father_middle_name
		assert_not_nil study_subject.father_last_name
		assert_equal 'Santa Claus', study_subject.fathers_name 
	end

	test "should return join of father's name with blank middle name" do
		study_subject = create_study_subject(
			:father_first_name  => "Santa",
			:father_middle_name => "",
			:father_last_name   => "Claus" )
		assert_not_nil study_subject.father_first_name
		assert_nil     study_subject.father_middle_name	#	SAVED SO YES NIL
		assert_not_nil study_subject.father_last_name
		assert_equal 'Santa Claus', study_subject.fathers_name 
	end

	test "should return join of mother's name" do
		study_subject = create_study_subject(
			:mother_first_name  => "Ms",
			:mother_middle_name => "X.",
			:mother_last_name   => "Claus" )
		assert_not_nil study_subject.mother_first_name
		assert_not_nil study_subject.mother_middle_name
		assert_not_nil study_subject.mother_last_name
		assert_equal 'Ms X. Claus', study_subject.mothers_name 
	end

	test "should return join of mother's name with maiden_name" do
		study_subject = create_study_subject(
			:mother_first_name  => "Ms",
			:mother_middle_name => "X.",				#	Do anything about a given period?
			:mother_maiden_name => "Hoopa",
			:mother_last_name   => "Claus" )
		assert_not_nil study_subject.mother_first_name
		assert_not_nil study_subject.mother_middle_name
		assert_not_nil study_subject.mother_maiden_name
		assert_not_nil study_subject.mother_last_name
		assert_equal 'Ms X. Hoopa Claus', study_subject.mothers_name 
	end

	test "should return join of mother's name without middle name" do
		study_subject = create_study_subject(
			:mother_first_name => "Ms",
			:mother_last_name  => "Claus" )
		assert_not_nil study_subject.mother_first_name
		assert_nil     study_subject.mother_middle_name
		assert_not_nil study_subject.mother_last_name
		assert_equal 'Ms Claus', study_subject.mothers_name 
	end

	test "should return join of mother's name with blank middle name" do
		study_subject = create_study_subject(
			:mother_first_name  => "Ms",
			:mother_middle_name => "",
			:mother_last_name   => "Claus" )
		assert_not_nil study_subject.mother_first_name
		assert_nil     study_subject.mother_middle_name	#	SAVED SO YES NIL
		assert_not_nil study_subject.mother_last_name
		assert_equal 'Ms Claus', study_subject.mothers_name 
	end

	test "should return join of guardian's name" do
		study_subject = create_study_subject(
			:guardian_first_name  => "Jack",
			:guardian_middle_name => "X.",
			:guardian_last_name   => "Frost" )
		assert_not_nil study_subject.guardian_first_name
		assert_not_nil study_subject.guardian_middle_name
		assert_not_nil study_subject.guardian_last_name
		assert_equal 'Jack X. Frost', study_subject.guardians_name 
	end

	test "should return join of guardian's name without middle name" do
		study_subject = create_study_subject(
			:guardian_first_name => "Jack",
			:guardian_last_name  => "Frost" )
		assert_not_nil study_subject.guardian_first_name
		assert_nil     study_subject.guardian_middle_name
		assert_not_nil study_subject.guardian_last_name
		assert_equal 'Jack Frost', study_subject.guardians_name 
	end

	test "should return join of guardian's name with blank middle name" do
		study_subject = create_study_subject(
			:guardian_first_name  => "Jack",
			:guardian_middle_name => "",
			:guardian_last_name   => "Frost" )
		assert_not_nil study_subject.guardian_first_name
		assert_nil     study_subject.guardian_middle_name	#	SAVED SO YES NIL
		assert_not_nil study_subject.guardian_last_name
		assert_equal 'Jack Frost', study_subject.guardians_name 
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
