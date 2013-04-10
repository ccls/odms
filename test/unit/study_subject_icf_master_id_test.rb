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




	test "should copy case's icf_master_id to case_icf_master_id for case (self)" do
		case_subject = FactoryGirl.build(:case_study_subject, :icf_master_id => 'Fake1234')
		assert_nil case_subject.case_icf_master_id
		case_subject.save
		assert_not_nil case_subject.reload.case_icf_master_id
		assert_equal case_subject.case_icf_master_id, case_subject.icf_master_id
	end

	test "should copy case's icf_master_id to case_icf_master_id for control" do
		case_subject = FactoryGirl.create(:case_study_subject, :icf_master_id => 'Fake1234')
		control_subject = FactoryGirl.build(:control_study_subject, 
			:matchingid => case_subject.subjectid)
		assert_nil control_subject.case_icf_master_id
		control_subject.save
		assert_not_nil control_subject.reload.case_icf_master_id
		assert_equal control_subject.case_icf_master_id, case_subject.icf_master_id
	end

	test "should copy case's icf_master_id to case_icf_master_id for case mother" do
		case_subject = FactoryGirl.create(:case_study_subject, :icf_master_id => 'Fake1234')
		mother_subject = FactoryGirl.build(:mother_study_subject, 
			:familyid   => case_subject.subjectid,
			:matchingid => case_subject.subjectid)
		assert_nil mother_subject.case_icf_master_id
		mother_subject.save
		assert_not_nil mother_subject.reload.case_icf_master_id
		assert_equal mother_subject.case_icf_master_id, case_subject.icf_master_id
	end

	test "should copy case's icf_master_id to case_icf_master_id for control mother" do
		case_subject = FactoryGirl.create(:case_study_subject, :icf_master_id => 'Fake1234')
		#	control subject doesn't need to exist
		mother_subject = FactoryGirl.build(:mother_study_subject, 
			:matchingid => case_subject.subjectid)
		assert_nil mother_subject.case_icf_master_id
		mother_subject.save
		assert_not_nil mother_subject.reload.case_icf_master_id
		assert_equal mother_subject.case_icf_master_id, case_subject.icf_master_id
	end



	test "should copy mother's icf_master_id to mother_icf_master_id for case mother" do
		case_subject = FactoryGirl.create(:case_study_subject)
		assert_nil case_subject.mother_icf_master_id
		mother_subject = FactoryGirl.create(:mother_study_subject, 
			:icf_master_id => 'Fake1234',
			:familyid   => case_subject.subjectid,
			:matchingid => case_subject.subjectid)
#		assert_nil case_subject.reload.mother_icf_master_id
#		case_subject.save
		assert_not_nil case_subject.reload.mother_icf_master_id
		assert_equal mother_subject.icf_master_id, case_subject.mother_icf_master_id
	end

	test "should copy mother's icf_master_id to mother_icf_master_id for control mother" do
		control_subject = FactoryGirl.create(:control_study_subject)
		assert_nil control_subject.mother_icf_master_id
		mother_subject = FactoryGirl.create(:mother_study_subject, 
			:icf_master_id => 'Fake1234',
			:familyid   => control_subject.subjectid)
#		assert_nil control_subject.reload.mother_icf_master_id
#		control_subject.save
		assert_not_nil control_subject.reload.mother_icf_master_id
		assert_equal mother_subject.icf_master_id, control_subject.mother_icf_master_id
	end






protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end
