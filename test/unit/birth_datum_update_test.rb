require 'test_helper'

class BirthDatumUpdateTest < ActiveSupport::TestCase
	include BirthDatumUpdateTestHelper

	assert_should_have_many(:birth_data)

	setup :turn_off_paperclip_logging
	#
	#	NOTE that paperclip attachments apparently don't get removed
	#		so we must do it on our own.  In addition, if the test
	#		fails before you do so, these files end up lying around.
	#		A bit of a pain in the butt.  So I added this explicit
	#		cleanup of the birth_datum_update csv_files.
	#		Works very nicely.
	#
	teardown :delete_all_possible_birth_datum_update_attachments

	test "explicit Factory birth_datum_update test" do
		assert_difference('CandidateControl.count',0) {	#	after_create should do nothing
		assert_difference('BirthDatum.count',0) {	#	after_create should do nothing
		assert_difference('BirthDatumUpdate.count',1) {
			birth_datum_update = Factory(:birth_datum_update)
			assert_not_nil birth_datum_update.csv_file_file_name
			assert_equal   birth_datum_update.csv_file_file_name, 
				'empty_birth_datum_update_test_file.csv'
			assert_not_nil birth_datum_update.csv_file_content_type
			assert_equal birth_datum_update.csv_file_content_type,
				'text/csv'
			assert_not_nil birth_datum_update.csv_file_file_size
			assert_not_nil birth_datum_update.csv_file_updated_at
		} } }
	end

	test "explicit Factory empty_birth_datum_update test" do
		assert_difference('CandidateControl.count',0) {	#	after_create should do nothing
		assert_difference('BirthDatum.count',0) {	#	after_create should do nothing
		assert_difference('BirthDatumUpdate.count',1) {
			birth_datum_update = Factory(:empty_birth_datum_update)
			assert_not_nil birth_datum_update.csv_file_file_name
			assert_equal   birth_datum_update.csv_file_file_name, 
				'empty_birth_datum_update_test_file.csv'
			assert_not_nil birth_datum_update.csv_file_content_type
			assert_equal birth_datum_update.csv_file_content_type,
				'text/csv'
			assert_not_nil birth_datum_update.csv_file_file_size
			assert_not_nil birth_datum_update.csv_file_updated_at
			assert_nil birth_datum_update.birth_data.first
		} } }
	end

	test "explicit Factory one_record_birth_datum_update test" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('CandidateControl.count',1) {	#	after_create should add this
		assert_difference('BirthDatum.count',1) {	#	after_create should add this
		assert_difference('BirthDatumUpdate.count',1) {
			birth_datum_update = Factory(:one_record_birth_datum_update)
			assert_not_nil birth_datum_update.csv_file_file_name
			assert_equal   birth_datum_update.csv_file_file_name, 
				'one_record_birth_datum_update_test_file.csv'
			assert_not_nil birth_datum_update.csv_file_content_type
			assert_equal birth_datum_update.csv_file_content_type,
				'text/csv'
			assert_not_nil birth_datum_update.csv_file_file_size
			assert_not_nil birth_datum_update.csv_file_updated_at
			assert_not_nil birth_datum_update.birth_data.first
			assert_not_nil birth_datum_update.birth_data.first.candidate_control
		} } }
	end

	test "should require csv_file" do
		birth_datum_update = BirthDatumUpdate.new
		assert !birth_datum_update.valid?
		assert  birth_datum_update.errors.include?(:csv_file)
	end

	test "should allow that attached csv_file content_type be text/plain" do
		birth_datum_update = BirthDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_birth_datum_update_test_file.csv', 'text/plain') )
		birth_datum_update.valid?
		assert !birth_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should allow that attached csv_file content_type be text/csv" do
		birth_datum_update = BirthDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_birth_datum_update_test_file.csv', 'text/csv') )
		birth_datum_update.valid?
		assert !birth_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should allow that attached csv_file content_type be application/vnd.ms-excel" do
		birth_datum_update = BirthDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_birth_datum_update_test_file.csv', 'application/vnd.ms-excel') )
		birth_datum_update.valid?
		assert !birth_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should require that attached csv_file be csv" do
		birth_datum_update = BirthDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_birth_datum_update_test_file.csv', 'text/funky') )
		assert !birth_datum_update.valid?
		assert  birth_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should require expected column names in csv file" do
		birth_datum_update = BirthDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/bad_header_test_file.csv', 'text/csv') )
		assert !birth_datum_update.valid?
		assert  birth_datum_update.errors.include?(:csv_file)
		assert  birth_datum_update.errors.matching?(:csv_file,
			'Invalid column name .* in csv_file')
	end

	test "should convert empty attached csv_file to candidate controls" do
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',0) {
			birth_datum_update = Factory(:empty_birth_datum_update)
		} }
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
		cleanup_birth_datum_update_and_test_file
	end

	test "should convert attached csv_file but no candidate controls with missing case" do
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',2) {
		assert_difference('OdmsException.count',2) {
			#
			#	Shouldn't happen, but matching case DOES NOT EXIST and get a control
			#	Should do something special here, like create an OdmsException
			#
			birth_datum_update = create_test_file_and_birth_datum_update
			assert_equal 2, birth_datum_update.birth_data.length
			birth_datum_update.birth_data.each do |birth_datum|
				assert_match /No subject found with masterid :\w+:/,
					birth_datum.odms_exceptions.first.notes
			end
		} } }
		cleanup_birth_datum_update_and_test_file
	end

	test "should copy attributes when csv_file converted to candidate control" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',2) {
		assert_difference('OdmsException.count',0) {
			birth_datum_update = create_test_file_and_birth_datum_update
#			results = birth_datum_update.to_candidate_controls
#			assert_equal 2,  results.length
#			candidate_control = results.last
#			assert_equal candidate_control.related_patid, study_subject.patid
#			assert_equal candidate_control.mom_is_biomom, control[:biomom]
#			assert_equal candidate_control.dad_is_biodad, control[:biodad]
##control[:date]},#{
#			assert_equal candidate_control.mother_full_name, control[:mother_full_name]
#			assert_equal candidate_control.mother_maiden_name, control[:mother_maiden_name]
##control[:father_full_name]},#{
#			assert_equal candidate_control.full_name, control[:child_full_name]
#			assert_equal candidate_control.dob, 
#				Date.new(control[:child_doby], control[:child_dobm], control[:child_dobd])
##				Date.new(control[:child_doby].to_i, control[:child_dobm].to_i, control[:child_dobd].to_i)
#			assert_equal candidate_control.sex, control[:child_gender]
##control[:birthplace_country]},#{
##control[:birthplace_state]},#{
##control[:birthplace_city]},#{
#			assert_equal candidate_control.mother_hispanicity_id, control[:mother_hispanicity]
##control[:mother_hispanicity_mex]},#{
#			assert_equal candidate_control.mother_race_id, control[:mother_race]
##control[:other_mother_race]},#{
#			assert_equal candidate_control.father_hispanicity_id, control[:father_hispanicity]
##control[:father_hispanicity_mex]},#{
#			assert_equal candidate_control.father_race_id, control[:father_race]
##control[:other_father_race]}} }
		} } }
		cleanup_birth_datum_update_and_test_file
	end

	test "should test with real data file" do
		#	real data and won't be in repository
		unless File.exists?('test-livebirthdata_011912.csv')	#	no longer valid file
			puts
			puts "-- Real data test file does not exist. Skipping."
			return 
		end

#		#	minimal semi-real case creation
#		s0 = Factory(:case_study_subject,:sex => 'F',
#			:first_name => 'FakeFirst1',:last_name => 'FakeLast1', 
#			:dob => Date.parse('10/16/1977'))
#		#	s0 has no icf_master_id, so should be ignored
#
#		s1 = Factory(:case_study_subject,:sex => 'F',
#			:first_name => 'FakeFirst2',:last_name => 'FakeLast2', 
#			:dob => Date.parse('9/21/1988'))
#		Factory(:icf_master_id,:icf_master_id => '48882638A')
#		s1.assign_icf_master_id
#
#		s2 = Factory(:case_study_subject,:sex => 'M',
#			:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
#			:dob => Date.parse('6/1/2009'))
#		Factory(:icf_master_id,:icf_master_id => '16655682G')
#		s2.assign_icf_master_id
#
#		birth_datum_update = Factory(:birth_datum_update,
#			:csv_file => File.open('test-livebirthdata_011912.csv') )
#		assert_not_nil birth_datum_update.csv_file_file_name
#
#		#	35 lines - 1 header - 3 cases = 31
#		assert_difference('CandidateControl.count',31){
#			results = birth_datum_update.to_candidate_controls
#			assert results[0].is_a?(String)
#			assert_equal results[0],
#				"Could not find study_subject with masterid [no ID assigned]"
#			assert results[1].is_a?(StudySubject)
#			assert results[2].is_a?(StudySubject)
#			assert_equal results[1], s1
#			assert_equal results[2], s2
#			results.each { |r|
#				if r.is_a?(CandidateControl) and r.new_record?
#					puts r.inspect
#					puts r.errors.full_messages.to_sentence
#				end
#			}
#		}
#		birth_datum_update.destroy
	end

	test "should return a StudySubject in results for case" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject }
		assert_difference('OdmsException.count',0){
		assert_difference('CandidateControl.count',0){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
		} } }
		cleanup_birth_datum_update_and_test_file
	end

	test "should return a CandidateControl in results for control" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_control }
		assert_difference('OdmsException.count',0){
		assert_difference('CandidateControl.count',1){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
		} } }
		cleanup_birth_datum_update_and_test_file
	end

	test "should return a String in results for unknown case_control_flag" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_unknown }
		assert_difference('OdmsException.count',1){
		assert_difference('CandidateControl.count',0){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
			assert_equal 1, birth_datum_update.birth_data.length
			birth_datum_update.birth_data.each do |birth_datum|
				assert_match /Unknown case_control_flag/,
					birth_datum.odms_exceptions.first.notes
			end
		} } }
		cleanup_birth_datum_update_and_test_file
	end

	test "should create odms exception if birth datum creation fails" do
pending	#	TODO
#1.Any records that fail to append will be noted in the odms_exceptions table with an exception-specific error message (to be defined at the judgment of the programmer) as follows:
#a.name: “birth_data append” 
#b.description:  programmer-specified error (to include master_id or errant record) or “Error importing record into birth_data table.  Exception record master_id = xxxxxxxxx.”  or “Error importing record into birth_data table.  Exception record master_id not provided.”
#c.occurred_at: timestamp
	end

	test "should create odms exception if birth datum count incorrect" do
pending	#	TODO
#1.When the appends are complete, if the count of records added to birth_data does not match the count of records in the uploaded birth_data table a record will be added as follows:
#a.name: “birth_data append” 
#b.description: “Birth data upload validation failed:  incorrect number of birth data records appended to birth_data.”
#c.occurred_at: timestamp
	end

protected

	def delete_all_possible_birth_datum_update_attachments
		#	/bin/rm -rf test/birth_datum_update
		FileUtils.rm_rf('test/birth_datum_update')
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_birth_datum_update

end
