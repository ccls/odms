require 'test_helper'

#	This is just a collection of race related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectRacesTest < ActiveSupport::TestCase

	test "should create study_subject with race" do
		assert_difference( 'Race.count', 1 ){
		assert_difference( 'SubjectRace.count', 1 ){
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = create_study_subject
			study_subject.races << FactoryGirl.create(:race)
			assert study_subject.persisted?,
				"#{study_subject.errors.full_messages.to_sentence}"
		} } }
	end

	test "should NOT destroy races with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('Race.count',1) {
			@study_subject = FactoryGirl.create(:subject_race).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('Race.count',0) {
			@study_subject.destroy
		} }
	end

	test "should NOT destroy subject_races with study_subject" do
		assert_difference('StudySubject.count',1) {
		assert_difference('SubjectRace.count',1) {
			@study_subject = FactoryGirl.create(:subject_race).study_subject
		} }
		assert_difference('StudySubject.count',-1) {
		assert_difference('SubjectRace.count',0) {
			@study_subject.destroy
		} }
	end

	test "should return race name for string" do
		study_subject = create_study_subject
		assert_equal study_subject.race_names, 
			"#{study_subject.races.first}"
	end

	test "should create study_subject with empty subject_races_attributes" do
		assert_difference( 'SubjectRace.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => { })
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert @study_subject.races.empty?
		assert @study_subject.subject_races.empty?
	end

	test "should create study_subject with blank race_code" do
		assert_difference( 'SubjectRace.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => { 
				'0' => { :race_code => '' }
			})
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert @study_subject.races.empty?
		assert @study_subject.subject_races.empty?
	end

	test "should create study_subject with subject_races_attributes race_code" do
		assert Race.count > 0
		assert_difference( 'SubjectRace.count', 1 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :race_code => Race.first.code }
			})
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert !@study_subject.races.empty?
		assert !@study_subject.subject_races.empty?
		assert !@study_subject.subject_races.first.is_primary
	end

#
#	is_primary is completely irrelevant
#
	test "should create study_subject with subject_races_attributes race_code and is_primary" do
		assert Race.count > 0
		assert_difference( 'SubjectRace.count', 1 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :race_code => Race.first.code, :is_primary => 'true' }
			})
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert !@study_subject.races.empty?
		assert !@study_subject.subject_races.empty?
		assert  @study_subject.subject_races.first.is_primary
	end

	test "should create study_subject with subject_races_attributes multiple races" do
		assert Race.count > 2
		races = Race.all.to_a
		assert_difference( 'SubjectRace.count', 3 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :race_code => races[1].code },
				'1' => { :race_code => races[2].code },
				'2' => { :race_code => races[3].code }
			})
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert !@study_subject.races.empty?
		assert_equal 3, @study_subject.races.length
		assert !@study_subject.subject_races.empty?
		assert_equal 3, @study_subject.subject_races.length
		assert !@study_subject.subject_races.collect(&:is_primary).any?
	end

	test "should create study_subject with subject_races_attributes multiple races and is_primaries" do
		assert Race.count > 2
		races = Race.all.to_a
		assert_difference( 'SubjectRace.count', 3 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :race_code => races[1].code, :is_primary => 'true' },
				'1' => { :race_code => races[2].code, :is_primary => 'true' },
				'2' => { :race_code => races[3].code, :is_primary => 'true' }
			})
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert !@study_subject.races.empty?
		assert_equal 3, @study_subject.races.length
		assert !@study_subject.subject_races.empty?
		assert_equal 3, @study_subject.subject_races.length
		assert  @study_subject.subject_races.collect(&:is_primary).all?
	end

	test "should create study_subject with subject_races_attributes with is_primary and no race_code" do
		assert Race.count > 0
		assert_difference( 'SubjectRace.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :is_primary => 'true' }
			})
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert @study_subject.races.empty?
		assert @study_subject.subject_races.empty?
	end

	test "should NOT create study_subject with subject_races_attributes " <<
			"if race is other_race and no other given" do
		assert Race.count > 0
		assert_difference( 'SubjectRace.count', 0 ){
		assert_difference( "StudySubject.count", 0 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :race_code => Race['other'].code }
			})
			assert @study_subject.errors.matching?("subject_races.other_race","can't be blank")
		} }
	end

	test "should NOT create study_subject with subject_races_attributes " <<
			"if race is mixed_race and no other given" do
		assert Race.count > 0
		assert_difference( 'SubjectRace.count', 0 ){
		assert_difference( "StudySubject.count", 0 ) {
			@study_subject = create_study_subject(:subject_races_attributes => {
				'0' => { :race_code => Race['mixed'].code }
			})
			assert @study_subject.errors.matching?("subject_races.mixed_race","can't be blank")
		} }
	end

	test "should update study_subject with subject_races_attributes" do
		assert Race.count > 0
		assert_difference( 'SubjectRace.count', 0 ){
		assert_difference( "StudySubject.count", 1 ) {
			@study_subject = create_study_subject
			assert @study_subject.persisted?, 
				"#{@study_subject.errors.full_messages.to_sentence}"
		} }
		assert @study_subject.races.empty?
		assert @study_subject.subject_races.empty?
		assert_difference( 'SubjectRace.count', 1 ){
		assert_difference( "StudySubject.count", 0 ) {
			@study_subject.update_attributes(:subject_races_attributes => {
				'0' => { :race_code => Race.first.code, :is_primary => 'true' }
			})
		} }
		@study_subject.reload
		assert !@study_subject.races.empty?
		assert !@study_subject.subject_races.empty?
		assert  @study_subject.subject_races.first.is_primary
	end

	test "should destroy subject_race on update with _destroy" do
		study_subject = create_study_subject
		assert_difference( 'SubjectRace.count', 1 ){
			study_subject.update_attributes(:subject_races_attributes => {
				'0' => { :race_code => Race.first.code, :is_primary => 'true' }
			})
		}
		subject_race = study_subject.subject_races.first
		assert_difference( 'SubjectRace.count', -1 ){
			study_subject.update_attributes(:subject_races_attributes => {
				'0' => { :id => subject_race.id, :_destroy => 1 }
			})
		}
	end

end
