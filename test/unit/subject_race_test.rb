require 'test_helper'

class SubjectRaceTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to( :study_subject, :race )
	assert_should_protect( :study_subject_id, :study_subject )

	test "explicit Factory subject_race test" do
		assert_difference('Race.count',1) {
		assert_difference('StudySubject.count',1) {
		assert_difference('SubjectRace.count',1) {
			subject_race = Factory(:subject_race)
			assert_not_nil subject_race.study_subject
			assert_not_nil subject_race.race
		} } }
	end

	test "should require other_race if race == other" do
		assert_difference( "SubjectRace.count", 0 ) do
			subject_race = create_subject_race(
				:race_id => Race['other'].id )
			assert subject_race.errors.matching?(:other_race,"can't be blank")
		end
	end

	test "should not require other_race if race != other" do
		assert_difference( "SubjectRace.count", 1 ) do
			subject_race = create_subject_race(
				:race_id => Race['white'].id )
			assert !subject_race.errors.matching?(:other_race,"can't be blank")
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_subject_race

end
