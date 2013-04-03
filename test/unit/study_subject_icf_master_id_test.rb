require 'test_helper'

class StudySubjectIcfMasterIdTest < ActiveSupport::TestCase

	assert_should_protect( :icf_master_id, 
		:model => 'StudySubject' )

	assert_should_require_attribute_length( :icf_master_id, 
		:model => 'StudySubject',
			:maximum => 9 )

	test "should not assign icf_master_id when there are none" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => nil)
		study_subject.assign_icf_master_id
		assert_nil study_subject.icf_master_id
	end

	test "should not assign icf_master_id if already have one and one exists" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_nil study_subject.reload.icf_master_id
		imi1 = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345678A')
		study_subject.assign_icf_master_id
		assert_equal imi1.icf_master_id, study_subject.reload.icf_master_id
		imi2 = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345678B')
		study_subject.assign_icf_master_id
		assert_equal imi1.icf_master_id, study_subject.reload.icf_master_id
	end

	test "should assign icf_master_id when there is one" do
		study_subject = create_study_subject
		imi = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345678A')
		study_subject.assign_icf_master_id
		assert_not_nil study_subject.icf_master_id
		assert_equal '12345678A', study_subject.icf_master_id
		imi.reload
		assert_not_nil imi.assigned_on
		assert_equal Date.current, imi.assigned_on
		assert_not_nil imi.study_subject_id
		assert_equal imi.study_subject_id, study_subject.id
	end

	test "should assign icf_master_id to mother on creation if one exists" do
		study_subject = create_study_subject
		imi = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345678A')
		assert_equal '12345678A', imi.icf_master_id
		mother = study_subject.create_mother
		assert_not_nil mother.reload.icf_master_id
		assert_equal '12345678A', mother.icf_master_id
	end

	test "should not assign icf_master_id to mother on creation if none exist" do
		study_subject = create_study_subject
		mother = study_subject.create_mother
		assert_nil mother.reload.icf_master_id
	end

	test "should return 'no ID assigned' if study_subject has no icf_master_id" do
		study_subject = create_study_subject
		assert_nil   study_subject.icf_master_id
		assert_equal study_subject.icf_master_id_to_s, '[no ID assigned]'
	end

	test "should return icf_master_id if study_subject has icf_master_id" do
		study_subject = create_study_subject
		assert_nil   study_subject.icf_master_id
		assert_equal study_subject.icf_master_id_to_s, '[no ID assigned]'
		imi = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345678A')
		study_subject.assign_icf_master_id
		assert_not_nil study_subject.icf_master_id
		assert_equal   study_subject.icf_master_id, imi.icf_master_id
		assert_equal   study_subject.icf_master_id_to_s, imi.icf_master_id
	end

	test "should require unique icf_master_id" do
		assert_difference('StudySubject.count',1){
			FactoryGirl.create(:study_subject, :icf_master_id => 'Fake1234')
		}
		assert_difference('StudySubject.count',0){
			study_subject = FactoryGirl.build(:study_subject, :icf_master_id => 'Fake1234')
			study_subject.save
			assert study_subject.errors.matching?(:icf_master_id,'has already been taken')
		}
	end


protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
