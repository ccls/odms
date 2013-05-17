require 'test_helper'

class SubjectRaceTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_initially_belong_to( :study_subject, :race )
	assert_should_protect( :study_subject_id, :study_subject )

	test "subject_race factory should create subject race" do
		assert_difference('SubjectRace.count',1) {
			subject_race = FactoryGirl.create(:subject_race)
		}
	end

	test "subject_race factory should create race" do
		assert_difference('Race.count',1) {
			subject_race = FactoryGirl.create(:subject_race)
			assert_not_nil subject_race.race
		}
	end

	test "subject_race factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			subject_race = FactoryGirl.create(:subject_race)
			assert_not_nil subject_race.study_subject
		}
	end

	test "should require other_race if race == other" do
		assert_difference( "SubjectRace.count", 0 ) do
			subject_race = create_subject_race(
				:race_code => Race['other'].code )
			assert subject_race.errors.matching?(:other_race,"can't be blank")
		end
	end
#
#	mixed_race is just an alias for other_race
#
	test "should require mixed_race if race == mixed" do
		assert_difference( "SubjectRace.count", 0 ) do
			subject_race = create_subject_race(
				:race_code => Race['mixed'].code )
			assert subject_race.errors.matching?(:mixed_race,"can't be blank")
		end
	end

	test "should not require other_race if race != other" do
		assert_difference( "SubjectRace.count", 1 ) do
			subject_race = create_subject_race(
				:race_code => Race['white'].code )
			assert !subject_race.errors.matching?(:other_race,"can't be blank")
		end
	end

	test "race_is_other should return true if race is other" do
		subject_race = FactoryGirl.create(:subject_race, 
			:race => Race['other'],
			:other_race => 'Funky' )
		assert subject_race.race_is_other?
	end

	test "race_is_mixed should return true if race is mixed" do
		subject_race = FactoryGirl.create(:subject_race, 
			:race => Race['mixed'],
			:other_race => 'Funky' )
		assert subject_race.race_is_mixed?
	end

	test "race_is_other should return false if race is not other" do
		subject_race = FactoryGirl.create(:subject_race, :race => Race['white'])
		assert !subject_race.race_is_other?
	end

	test "race_is_mixed should return false if race is not mixed" do
		subject_race = FactoryGirl.create(:subject_race, :race => Race['white'])
		assert !subject_race.race_is_mixed?
	end

	test "to_s should return race description if english" do
		subject_race = FactoryGirl.create(:subject_race, :race => Race['white'])
		assert_equal subject_race.to_s, 'White, Non-Hispanic'
	end

	test "to_s should return race description if spanish" do
		subject_race = FactoryGirl.create(:subject_race, :race => Race['black'])
		assert_equal subject_race.to_s, 'Black / African American'
	end


	test "should flag study subject for reindexed on create" do
		subject_race = FactoryGirl.create(:subject_race)
		assert_not_nil subject_race.study_subject
		assert  subject_race.study_subject.needs_reindexed
	end

	test "should flag study subject for reindexed on update" do
		subject_race = FactoryGirl.create(:subject_race)
		assert_not_nil subject_race.study_subject
		assert  subject_race.study_subject.needs_reindexed
		subject_race.study_subject.update_attribute(:needs_reindexed, false)
		assert !subject_race.study_subject.needs_reindexed
		subject_race.update_attributes(:other_race => "something to make it dirty")
		assert  subject_race.study_subject.needs_reindexed
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_subject_race

end
