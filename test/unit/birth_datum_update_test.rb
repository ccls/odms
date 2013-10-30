require 'test_helper'

class BirthDatumUpdateTest < ActiveSupport::TestCase

	teardown :cleanup_birth_datum_update_and_test_file	#	remove tmp/FILE.csv

	test "birth datum update factory should not create birth datum" do
		assert_difference('BirthDatum.count',0) {	#	after_create should do nothing
			BirthDatumUpdate.new('test/assets/empty_birth_datum_update_test_file.csv')
		}
	end

	test "birth datum update factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {	#	after_create should do nothing
			BirthDatumUpdate.new('test/assets/empty_birth_datum_update_test_file.csv')
		}
	end

	test "one record birth datum update factory should create birth datum" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('BirthDatum.count',1) {	#	after_create should add this
			birth_datum_update = BirthDatumUpdate.new(
				'test/assets/one_record_birth_datum_update_test_file.csv')
			assert_not_nil birth_datum_update.birth_data.first
			assert_not_nil birth_datum_update.birth_data.first.candidate_control
		}
	end

	test "one record birth datum update factory should create candidate control" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('CandidateControl.count',1) {	#	after_create should add this
			birth_datum_update = BirthDatumUpdate.new(
				'test/assets/one_record_birth_datum_update_test_file.csv')
			assert_not_nil birth_datum_update.birth_data.first
			assert_not_nil birth_datum_update.birth_data.first.candidate_control
		}
	end

	test "should convert attached csv_file to candidate controls with matching case" do
		create_case_for_birth_datum_update
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',2) {
			#
			#	As expected.  Case exists and file contains a control
			#
			create_test_file_and_birth_datum_update
		} }
	end

	test "should convert attached csv_file but no candidate controls with missing case" do
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',2) {
			#
			#	Shouldn't happen, but matching case DOES NOT EXIST and get a control
			#
			birth_datum_update = create_test_file_and_birth_datum_update
			assert_equal 2, birth_datum_update.birth_data.length
			birth_datum_update.birth_data.each do |birth_datum|
				assert_match /No subject found with master_id :\w+:/,
					birth_datum.ccls_import_notes
			end
		} }
	end

	test "should copy attributes when csv_file converted to candidate control" do
		study_subject = create_case_for_birth_datum_update
#		study_subject = create_case_for_birth_datum_update({
#			:mother_ssn => '123456789',
#			:father_ssn => '987654321'})
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',2) {
			birth_datum_update = create_test_file_and_birth_datum_update

			require 'csv'
#			f=CSV.open( birth_datum_update.csv_file.path, 'rb',{
			f=CSV.open( birth_datum_update.csv_file, 'rb',{
					:headers => true })
			line = f.readline	#	case
			birth_datum = birth_datum_update.birth_data[0]
#			birth_datum = BirthDatum.first
			assert_equal birth_datum.master_id, '12345FAKE'
			assert_equal birth_datum.case_control_flag, 'case'
			assert_equal birth_datum.match_confidence, 'definite'
			assert_equal birth_datum.sex, line['sex']
			assert_equal birth_datum.dob, Date.parse(line['dob'])

			line = f.readline	#	control
			birth_datum = birth_datum_update.birth_data[1]
#			birth_datum = BirthDatum.last
			assert_equal birth_datum.master_id, '12345FAKE'
			assert_equal birth_datum.case_control_flag, 'control'
			assert       birth_datum.match_confidence.blank?
			assert_equal birth_datum.sex, line['sex']
			assert_equal birth_datum.dob, Date.parse(line['dob'])
#			assert_equal birth_datum.mother_ssn, '123456789'
#			assert_equal birth_datum.father_ssn, '987654321'

			f.close
		} }
	end

	#	string (varchar(255)) columns
	%w( mother_ssn father_ssn 
birth_state
match_confidence
case_control_flag  
abnormal_conditions birth_type
complications_labor_delivery
complications_pregnancy
county_of_delivery
first_name
middle_name
last_name
father_industry
father_hispanic_origin_code
father_middle_name
father_last_name
father_occupation
fetal_presentation_at_birth
local_registrar_district
local_registrar_no
method_of_delivery
month_prenatal_care_began
mother_residence_line_1
mother_residence_city
mother_residence_county
mother_residence_county_ef
mother_residence_state
mother_residence_zip
mother_birthplace
mother_birthplace_state
mother_first_name
mother_middle_name
mother_maiden_name
mother_hispanic_origin_code
mother_industry
mother_occupation
sex
state_registrar_no
).each do |field|

		test "should copy #{field} from csv_file to birth_datum" do
			value = 'SOME TEST STRING'
			File.open(csv_test_file_name,'w'){|f|
				f.puts csv_file_header
				f.puts csv_file_unknown(field.to_sym => value) }
#			assert_difference('BirthDatumUpdate.count',1){
			assert_difference('BirthDatum.count',1){
				birth_datum_update = create_birth_datum_update_with_file
				assert_equal 1, birth_datum_update.birth_data.length
				assert_equal value,
					birth_datum_update.birth_data.first.send(field)
			} #}
		end

	end


	test "should test with real data file" do
		#	real data and won't be in repository
		real_data_file = "birth_data/birth_datum_update_20120424.csv"
		unless File.exists?(real_data_file)
			puts
			puts "-- Real data test file does not exist. Skipping."
			return 
		end

		#	case must exist for candidate controls to be created
		s = FactoryGirl.create(:case_study_subject,:sex => 'M',
			:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
			:dob => Date.parse('6/1/2009'))
		FactoryGirl.create(:icf_master_id,:icf_master_id => '15851196C')
		s.assign_icf_master_id

		birth_datum_update = nil

		assert_difference('BirthDatum.count',33){
		assert_difference('CandidateControl.count',5){
			birth_datum_update = BirthDatumUpdate.new(real_data_file) 
#			birth_datum_update.parse_csv_file
			assert_not_nil birth_datum_update.csv_file
		} }
	end

#
#	some of these test names are remnants and probably confusing
#

	test "should return a StudySubject in results for case" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject }
#	NOTE this is different from the subject so an exception is now created(don't know what this means)
		assert_difference('CandidateControl.count',0){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
		} }
	end

	test "should return a CandidateControl in results for control" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_control }
		assert_difference('CandidateControl.count',1){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
		} }
	end

	test "should return a String in results for unknown case_control_flag" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_unknown }
		assert_difference('CandidateControl.count',0){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
			assert_equal 1, birth_datum_update.birth_data.length
			birth_datum_update.birth_data.each do |birth_datum|
				assert_match /Unknown case_control_flag/,
					birth_datum.ccls_import_notes
			end
		} }
	end


#	what about other creation failures
#
#	test "should do what if creating candidate controls fails" do
#pending	#	bang or no bang?
#	end
#
#	test "should do what if creating operational event fails" do
#pending	#	bang or no bang?
#	end
#
#	test "should do what if updating study subject fails" do
#pending	#	bang or no bang?
#	end
#

	test "should mark associated case bc_requests as complete" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('BcRequest.active.count',1){
			study_subject.bc_requests.create(:status => 'active')
		}
		assert_difference('BcRequest.count',0){
		assert_difference('BcRequest.active.count',-1){
		assert_difference('BcRequest.complete.count',1){
			create_test_file_and_birth_datum_update
		} } }
		bcr = study_subject.bc_requests.first
		assert_not_nil bcr.is_found
		assert_not_nil bcr.returned_on
		assert_equal Date.current, bcr.returned_on
		assert_not_nil bcr.notes
		assert_equal "USC's match confidence = definite.", bcr.notes
	end

protected

	def create_test_file_and_birth_datum_update(options={})
		create_birth_datum_update_test_file(options)
		birth_datum_update = create_birth_datum_update_with_file
	end

	def create_birth_datum_update_with_file
		birth_datum_update = BirthDatumUpdate.new(csv_test_file_name)
		birth_datum_update
	end

	def cleanup_birth_datum_update_and_test_file(birth_datum_update=nil)
		if File.exists?(csv_test_file_name)
			#	explicit delete to remove test file
			File.delete(csv_test_file_name)	
		end
		assert !File.exists?(csv_test_file_name)
	end

	def create_case_for_birth_datum_update
		icf_master_id = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345FAKE')
		study_subject = FactoryGirl.create(:complete_case_study_subject)
		study_subject.assign_icf_master_id
		assert_equal '12345FAKE', study_subject.icf_master_id
		study_subject
	end

	def csv_file_header_array
		BirthDatumUpdate.expected_column_names
	end

	def csv_file_header
		csv_file_header_array.collect{|s|"\"#{s}\""}.join(',')
	end

	def csv_file_unknown(options={})
		c = unknown_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def csv_file_case_study_subject(options={})
		c = case_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def csv_file_control(options={})
		c = control_subject_hash.merge(options)
		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
	end

	def create_birth_datum_update_test_file(options={})
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject
			f.puts csv_file_control(options) }
	end

	#	just enough for no exceptions
	def unknown_subject_hash
		FactoryGirl.attributes_for(:birth_datum,
			:master_id => '12345FAKE' )
	end

	def case_subject_hash
		FactoryGirl.attributes_for(:case_birth_datum,
			:master_id => '12345FAKE' )
	end

	def control_subject_hash
		FactoryGirl.attributes_for(:control_birth_datum,
			:master_id => '12345FAKE' )
	end

	#	shouldn't be called test_... as makes it a test method!
	def csv_test_file_name
		"tmp/birth_datum_update_test_file.csv"
	end

end
