require 'test_helper'

class SubjectLanguageTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to( :study_subject, :language )
	assert_should_protect( :study_subject_id, :study_subject )

	test "subject_language factory should create subject language" do
		assert_difference('SubjectLanguage.count',1) {
			subject_language = Factory(:subject_language)
		}
	end

	test "subject_language factory should create language" do
		assert_difference('Language.count',1) {
			subject_language = Factory(:subject_language)
			assert_not_nil subject_language.language
		}
	end

	test "subject_language factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			subject_language = Factory(:subject_language)
			assert_not_nil subject_language.study_subject
		}
	end

	test "should require other_language if language == other" do
		assert_difference( "SubjectLanguage.count", 0 ) do
			subject_language = create_subject_language(
				:language_id => Language['other'].id )
			assert subject_language.errors.matching?(:other_language,"can't be blank")
		end
	end

	test "should not require other_language if language != other" do
		assert_difference( "SubjectLanguage.count", 1 ) do
			subject_language = create_subject_language(
				:language_id => Language['ENglish'].id )
			assert !subject_language.errors.matching?(:other_language,"can't be blank")
		end
	end

	test "language_is_other should return true if language is other" do
		subject_language = Factory(:subject_language, 
			:language => Language['other'],
			:other_language => 'redneck' )
		assert subject_language.language_is_other?
	end

	test "language_is_other should return false if language is not other" do
		subject_language = Factory(:subject_language, :language => Language['english'])
		assert !subject_language.language_is_other?
	end

	test "to_s should return language description if english" do
		subject_language = Factory(:subject_language, :language => Language['ENglish'])
		assert_equal subject_language.to_s, 'English'
	end

	test "to_s should return language description if spanish" do
		subject_language = Factory(:subject_language, :language => Language['spanish'])
		assert_equal subject_language.to_s, 'Spanish'
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_subject_language

end
