require 'test_helper'

#	This is just a collection of identifier related tests 
#	for StudySubject separated only for clarity due
#	to the size of the StudySubjectTest class.
class StudySubjectIdentifierTest < ActiveSupport::TestCase

	test "studyid should be patid, case_control_type and orderno" do
		StudySubject.any_instance.stubs(:get_next_patid).returns('123')
		study_subject = FactoryGirl.create(:case_study_subject)
		assert study_subject.is_case?
		assert_not_nil study_subject.studyid
		assert_equal "0123-C-0", study_subject.studyid
	end

	test "should create study subject with specified matchingid" do
		#	just to make sure that this method is defined
		#	get funny errors when accidentally comment out.
		assert_difference('StudySubject.count',1) {
			study_subject = create_study_subject(:matchingid => '54321')
			assert_equal '054321', study_subject.matchingid
		}
	end

	[ :state_id_no, :state_registrar_no, :local_registrar_no, 
		:studyid, :subjectid ].each do |attr|

		#	childid is numeric, so this won't be true
		test "should nilify blank #{attr} before validation" do
			#	NEED block for protected attributes
			study_subject = StudySubject.new{|s| s.send("#{attr}=",'   ')}
			assert  study_subject.send(attr).blank?
			assert !study_subject.send(attr).nil?
			study_subject.valid?
			assert  study_subject.send(attr).blank?
			assert  study_subject.send(attr).nil?
		end 

	end
 
#	test "should pad subjectid with leading zeros before validation" do
#		study_subject = FactoryGirl.build(:study_subject)
#		assert study_subject.subjectid.length < 6 
#		study_subject.valid?	#save
#		assert study_subject.subjectid.length == 6
#	end 

	test "should pad matchingid with leading zeros before validation" do
		study_subject = FactoryGirl.build(:study_subject,{ :matchingid => '123' })
		assert study_subject.matchingid.length < 6 
		assert_equal '123', study_subject.matchingid
		study_subject.valid?	#save
		assert study_subject.matchingid.length == 6
		assert_equal '000123', study_subject.matchingid
	end 

	test "should pad patid with leading zeros before validation" do
		study_subject = FactoryGirl.build(:study_subject)
		study_subject.patid = '123'
		assert study_subject.patid.length < 4
		assert_equal '123', study_subject.patid
		study_subject.valid?	#save
		assert study_subject.patid.length == 4
		assert_equal '0123', study_subject.patid
	end 

	test "should upcase sex before validation" do
		study_subject = FactoryGirl.build(:study_subject,:sex => 'dk')
		assert_equal 'dk', study_subject.sex
		assert study_subject.valid?
		assert_equal 'DK', study_subject.sex
	end

#	patid and childid should be protected as they are generated values

	test "should generate orderno = 0 for case_control_type == 'c'" do
		#	case_control_type is NOT the trigger.  SubjectType is.
		study_subject = FactoryGirl.create(:case_study_subject).reload
		assert_equal 0, study_subject.orderno
	end

	test "should not overwrite given studyid" do
		study_subject = FactoryGirl.create(:study_subject,:studyid => 'MyStudyId').reload
		assert_equal 'MyStudyId', study_subject.studyid
	end

	test "should set studyid with patid, case_control_type and orderno for" <<
			" case_control_type c" do
		StudySubject.any_instance.stubs(:get_next_patid).returns('123')
		study_subject = FactoryGirl.create(:case_study_subject).reload
		assert_equal "0123", study_subject.patid
		assert_equal "C", study_subject.case_control_type
		assert_equal "0", study_subject.orderno.to_s
		assert_not_nil study_subject.studyid
		assert_equal "0123-C-0", study_subject.studyid
	end

	test "should generate subjectid on creation for any study_subject" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_not_nil study_subject.subjectid
		assert study_subject.subjectid.length == 6
	end

	test "should generate patid on creation of case_control_type == 'c'" do
		assert_difference('StudySubject.maximum(:patid).to_i', 1) {
			study_subject = FactoryGirl.create(:case_study_subject).reload
			assert_not_nil study_subject.patid
		}
	end

	%w( c b f 4 5 6 ).each do |cct|

		test "should generate childid on creation of case_control_type #{cct}" do
			assert_difference('StudySubject.maximum(:childid).to_i', 1) {
				study_subject = FactoryGirl.create(:study_subject, :case_control_type => cct )
				assert_not_nil study_subject.childid
			}
		end

		test "should generate familyid == subjectid on creation of case_control_type #{cct}" do
			study_subject = FactoryGirl.create(:study_subject, :case_control_type => cct )
			assert_not_nil study_subject.subjectid
			assert_not_nil study_subject.familyid
			assert_equal   study_subject.subjectid, study_subject.familyid
		end

	end

	test "should generate familyid == child's subjectid on creation of case's mother" do
		case_study_subject = create_case_study_subject
		assert_equal case_study_subject.subjectid, case_study_subject.familyid
		mother = case_study_subject.create_mother
		assert_equal case_study_subject.subjectid, mother.familyid
	end

	test "should generate familyid == child's subjectid on creation of control's mother" do
		control_study_subject = create_control_study_subject
		assert_equal control_study_subject.subjectid, control_study_subject.familyid
		mother = control_study_subject.create_mother
		assert_equal control_study_subject.subjectid, mother.familyid
	end

	test "should generate matchingid == subjectid on creation of case" do
		study_subject = FactoryGirl.create(:case_study_subject).reload
		assert_not_nil study_subject.subjectid
		assert_not_nil study_subject.matchingid
		assert_equal   study_subject.subjectid, study_subject.matchingid
	end

	test "should not generate new patid for case if given" do
		#	existing data import
		assert_difference( "StudySubject.maximum(:patid).to_i", 123 ) {	#	was 0, now 123
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = FactoryGirl.create(:case_study_subject, :patid => '123').reload
			assert_not_nil study_subject.studyid
			assert_equal "0123-C-0", study_subject.studyid
			assert_equal "0123",     study_subject.patid
		} } #}
	end

	test "should not generate new childid if given" do
		#	existing data import
		assert_difference( "StudySubject.maximum(:childid).to_i", 123 ) {	#	was 0, now 123
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = FactoryGirl.create(:case_study_subject, :childid => '123').reload
			assert_equal 123, study_subject.childid
		} } #}
	end

	test "should not generate new orderno if given" do
		#	existing data import
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = FactoryGirl.create(:case_study_subject, :orderno => 9).reload
			assert_equal 9, study_subject.orderno
		}
	end

	test "should not generate new subjectid if given" do
		#	existing data import
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = FactoryGirl.create(:case_study_subject, :subjectid => 'ABCDEF').reload
			assert_equal "ABCDEF", study_subject.subjectid
		}
	end

	test "should not generate new familyid if given" do
		#	existing data import
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = FactoryGirl.create(:case_study_subject, :familyid => 'ABCDEF').reload
			assert_equal "ABCDEF", study_subject.familyid
		}
	end

	test "should not generate new matchingid if given" do
		#	existing data import
		assert_difference( "StudySubject.count", 1 ) {
			study_subject = FactoryGirl.create(:case_study_subject, :matchingid => '123456').reload
			assert_equal "123456", study_subject.matchingid
		}
	end







#	The problems with autogeneration of childid, patid and subjectid are
#	that they cannot be validated automatically.  Validation would simply
#	return this failure to the user, whom can do nothing about it.
#	Autogeneration must work on its own.  subjectid seems to effectively
#	select an unused subjectid, but if many subjects were being created at 
#	the same time could theoretically select the same random number.
#	If/When this occurs, a database error will be returned and confuse
#	the user.
#

#	ActiveRecord::StatementInvalid: Mysql::Error: Duplicate entry '12345' for key 'index_identifiers_on_childid': INSERT INTO `identifiers` (`familyid`, `created_at`, `case_control_type`, `childidwho`, `ssn`, `updated_at`, `state_id_no`, `matchingid`, `gbid`, `idno_wiemels`, `related_childid`, `state_registrar_no`, `study_subject_id`, `studyid`, `childid`, `studyid_nohyphen`, `icf_master_id`, `orderno`, `lab_no`, `lab_no_wiemels`, `accession_no`, `subjectid`, `newid`, `studyid_intonly_nohyphen`, `local_registrar_no`, `patid`, `related_case_childid`) VALUES('407928', '2011-10-28 12:36:07', '3', NULL, '000000002', '2011-10-28 12:36:07', '2', NULL, '2', '2', NULL, '2', 2, NULL, 12345, NULL, '2', NULL, NULL, '2', '2', '407928', NULL, NULL, '2', NULL, NULL)
	test "duplicating childid should raise database error" do
		StudySubject.any_instance.stubs(:get_next_childid).returns(12345)
		study_subject1 = FactoryGirl.create(:study_subject)
		assert_not_nil study_subject1.childid
#	rails 2
#		assert_raises(ActiveRecord::StatementInvalid){
#	rails 3
		assert_raises(ActiveRecord::RecordNotUnique){
			study_subject2 = FactoryGirl.create(:study_subject)
		}
	end

#	ActiveRecord::StatementInvalid: Mysql::Error: Duplicate entry '0123-C-0' for key 'piccton': INSERT INTO `identifiers` (`familyid`, `created_at`, `case_control_type`, `childidwho`, `ssn`, `updated_at`, `state_id_no`, `matchingid`, `gbid`, `idno_wiemels`, `related_childid`, `state_registrar_no`, `study_subject_id`, `studyid`, `childid`, `studyid_nohyphen`, `icf_master_id`, `orderno`, `lab_no`, `lab_no_wiemels`, `accession_no`, `subjectid`, `newid`, `studyid_intonly_nohyphen`, `local_registrar_no`, `patid`, `related_case_childid`) VALUES('975152', '2011-10-28 12:36:08', 'C', NULL, '000000004', '2011-10-28 12:36:08', '4', '975152', '4', '4', NULL, '4', 4, NULL, 2, NULL, '4', 0, NULL, '4', '4', '975152', NULL, NULL, '4', '0123', NULL)
	test "duplicating patid should raise database error" do
		StudySubject.any_instance.stubs(:get_next_patid).returns('0123')
		study_subject1 = FactoryGirl.create(:case_study_subject)
		assert_not_nil study_subject1.patid
#	rails 2
#		assert_raises(ActiveRecord::StatementInvalid){
#	rails 3
		assert_raises(ActiveRecord::RecordNotUnique){
			study_subject2 = FactoryGirl.create(:case_study_subject)
		}
	end

	#	This should never actually happen as the code actually removes all those that exist.
	#	But it does show that if/when creation of an identifier with an existing
	#		is attempted, it will raise a database error.
#	ActiveRecord::StatementInvalid: Mysql::Error: Duplicate entry '012345' for key 'index_identifiers_on_subjectid': INSERT INTO `identifiers` (`familyid`, `created_at`, `case_control_type`, `childidwho`, `ssn`, `updated_at`, `state_id_no`, `matchingid`, `gbid`, `idno_wiemels`, `related_childid`, `state_registrar_no`, `study_subject_id`, `studyid`, `childid`, `studyid_nohyphen`, `icf_master_id`, `orderno`, `lab_no`, `lab_no_wiemels`, `accession_no`, `subjectid`, `newid`, `studyid_intonly_nohyphen`, `local_registrar_no`, `patid`, `related_case_childid`) VALUES('012345', '2011-10-28 12:36:08', '5', NULL, '000000006', '2011-10-28 12:36:08', '6', NULL, '6', '6', NULL, '6', 6, NULL, 4, NULL, '6', NULL, NULL, '6', '6', '012345', NULL, NULL, '6', NULL, NULL)
	test "duplicating subjectid should raise database error" do
		StudySubject.any_instance.stubs(:generate_subjectid).returns('012345')
		study_subject1 = FactoryGirl.create(:study_subject)
		assert_not_nil study_subject1.subjectid
#	rails 2
#		assert_raises(ActiveRecord::StatementInvalid){
#	rails 3
		assert_raises(ActiveRecord::RecordNotUnique){
			study_subject2 = FactoryGirl.create(:study_subject)
		}
	end

end
