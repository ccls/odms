require 'test_helper'

#	This is just a collection of language related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectLanguagesTest < ActiveSupport::TestCase

	test "should create study_subject with language" do
		assert_difference( 'Language.count', 1 ){
		assert_difference( 'SubjectLanguage.count', 1 ){
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject
			study_subject.languages << Factory(:language)
			assert !study_subject.new_record?, 
				"#{study_subject.errors.full_messages.to_sentence}"
		} } }
	end

	test "should NOT destroy languages with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('SubjectLanguage.count',1) {
			@study_subject = Factory(:subject_language).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('SubjectLanguage.count',0) {
			@study_subject.destroy
		} }
	end

	test "should NOT destroy subject_languages with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('SubjectLanguage.count',1) {
			@study_subject = Factory(:subject_language).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('SubjectLanguage.count',0) {
			@study_subject.destroy
		} }
	end

#	add similar for languages?
#	test "should return race name for string" do
#		study_subject = create_study_subject
#		assert_equal study_subject.race_names,
#			"#{study_subject.races.first}"
#	end 

	test "should NOT create study_subject with empty subject_languages_attributes" <<
			" if language_required" do
		assert_difference( 'SubjectLanguage.count', 0 ){
		assert_difference( "StudySubject.count", 0 ) {
			@study_subject = create_study_subject(
				:language_required => true,
				:subject_languages_attributes => { })
			assert @study_subject.new_record?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
	end

	test "should create study_subject with empty subject_languages_attributes" do
		assert_difference( 'SubjectLanguage.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_languages_attributes => { })
			assert !@study_subject.new_record?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert @study_subject.languages.empty?
		assert @study_subject.subject_languages.empty?
	end

	test "should create study_subject with blank language_code" do
		assert_difference( 'SubjectLanguage.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_languages_attributes => { 
				'0' => { :language_code => '' }
			})
			assert !@study_subject.new_record?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert @study_subject.languages.empty?
		assert @study_subject.subject_languages.empty?
	end

	test "should create study_subject with subject_languages_attributes language_code" do
		assert Language.count > 0
		assert_difference( 'SubjectLanguage.count', 1 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_languages_attributes => {
				'0' => { :language_code => Language.order(:position).first.code }
			})
			assert !@study_subject.new_record?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert !@study_subject.languages.empty?
		assert_equal 1, @study_subject.languages.length
		assert !@study_subject.subject_languages.empty?
		assert_equal 1, @study_subject.subject_languages.length
	end

	test "should create study_subject with subject_languages_attributes multiple languages" do
		assert Language.count > 1
		languages = Language.order(:position).all
		assert_difference( 'SubjectLanguage.count', 2 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_languages_attributes => {
				'0' => { :language_code => languages[0].code },
				'1' => { :language_code => languages[1].code }
			})
			assert !@study_subject.new_record?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert !@study_subject.languages.empty?
		assert_equal 2, @study_subject.languages.length
		assert !@study_subject.subject_languages.empty?
		assert_equal 2, @study_subject.subject_languages.length
	end

	test "should NOT create study_subject with subject_languages_attributes " <<
			"if language is other and no other_language given" do
		assert Language.count > 0
		assert_difference( 'SubjectLanguage.count', 0 ){
		assert_difference( "StudySubject.count", 0 ) {
			@study_subject = create_study_subject(:subject_languages_attributes => {
				'0' => { :language_code => Language['other'].code }
			})
			assert @study_subject.errors.matching?("subject_languages.other_language","can't be blank")
		} }
	end

	test "should update study_subject with subject_languages_attributes" do
		study_subject = create_study_subject
		assert_difference( 'SubjectLanguage.count', 1 ){
			study_subject.update_attributes(:subject_languages_attributes => {
				'0' => { :language_code => Language.order(:position).first.code }
			})
		}
	end

	test "should destroy subject_language on update with _destroy" do
		study_subject = create_study_subject
		assert_difference( 'SubjectLanguage.count', 1 ){
			study_subject.update_attributes(:subject_languages_attributes => {
				'0' => { :language_code => Language.order(:position).first.code }
			})
		}
		subject_language = study_subject.subject_languages.first
		assert_difference( 'SubjectLanguage.count', -1 ){
			study_subject.update_attributes(:subject_languages_attributes => {
				'0' => { :id => subject_language.id, :_destroy => 1 }
			})
		}
	end

end
