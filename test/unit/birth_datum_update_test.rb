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

	teardown :cleanup_birth_datum_update_and_test_file	#	remove tmp/FILE.csv

	test "birth datum update factory should create birth datum update" do
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
		}
	end

	test "birth datum update factory should not create birth datum" do
		assert_difference('BirthDatum.count',0) {	#	after_create should do nothing
			birth_datum_update = Factory(:birth_datum_update)
		}
	end

	test "birth datum update factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {	#	after_create should do nothing
			birth_datum_update = Factory(:birth_datum_update)
		}
	end

	test "empty birth datum update factory should create birth datum update" do
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
		}
	end

	test "empty birth datum update factory should not create birth datum" do
		assert_difference('BirthDatum.count',0) {	#	after_create should do nothing
			birth_datum_update = Factory(:empty_birth_datum_update)
			assert_nil birth_datum_update.birth_data.first
		}
	end

	test "empty birth datum update factory should not create candidate control" do
		assert_difference('CandidateControl.count',0) {	#	after_create should do nothing
			birth_datum_update = Factory(:empty_birth_datum_update)
		}
	end

	test "one record birth datum update factory should create birth datum update" do
		study_subject = create_case_for_birth_datum_update
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
		}
	end

	test "one record birth datum update factory should create birth datum" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('BirthDatum.count',1) {	#	after_create should add this
			birth_datum_update = Factory(:one_record_birth_datum_update)
			assert_not_nil birth_datum_update.birth_data.first
			assert_not_nil birth_datum_update.birth_data.first.candidate_control
		}
	end

	test "one record birth datum update factory should create candidate control" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('CandidateControl.count',1) {	#	after_create should add this
			birth_datum_update = Factory(:one_record_birth_datum_update)
			assert_not_nil birth_datum_update.birth_data.first
			assert_not_nil birth_datum_update.birth_data.first.candidate_control
		}
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
skip 'Temporarily disabled this validation.'
		assert !birth_datum_update.valid?
		assert  birth_datum_update.errors.include?(:csv_file)
		assert  birth_datum_update.errors.matching?(:csv_file,
			'Invalid column name .* in csv_file')
	end

#	test "should convert empty attached csv_file to candidate controls" do
#		assert_difference('CandidateControl.count',0) {
#		assert_difference('BirthDatum.count',0) {
#			birth_datum_update = Factory(:empty_birth_datum_update)
#		} }
#	end

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
		assert_difference('OdmsException.count',2) {
			#
			#	Shouldn't happen, but matching case DOES NOT EXIST and get a control
			#	Should do something special here, like create an OdmsException
			#
			birth_datum_update = create_test_file_and_birth_datum_update
			assert_equal 2, birth_datum_update.birth_data.length
			birth_datum_update.birth_data.each do |birth_datum|
				assert_equal 'birth data append',
					birth_datum.odms_exceptions.first.name
				assert_match /No subject found with masterid :\w+:/,
					birth_datum.odms_exceptions.first.to_s
			end
		} } }
	end

	test "should copy attributes when csv_file converted to candidate control" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('CandidateControl.count',1) {
		assert_difference('BirthDatum.count',2) {
#	NOTE this case info is different than the subject so an odms exception is created
#		assert_difference('OdmsException.count',0) {
			birth_datum_update = create_test_file_and_birth_datum_update

			require 'csv'
			f=CSV.open( birth_datum_update.csv_file.path, 'rb',{
					:headers => true })
			line = f.readline	#	case
			birth_datum = birth_datum_update.birth_data[0]
			assert_equal birth_datum.masterid, '12345FAKE'
			assert_equal birth_datum.case_control_flag, 'case'
			assert_equal birth_datum.match_confidence, 'definite'
			assert_equal birth_datum.sex, line['sex']
			assert_equal birth_datum.dob, Date.parse(line['dob'])

			line = f.readline	#	control
			birth_datum = birth_datum_update.birth_data[1]
			assert_equal birth_datum.masterid, '12345FAKE'
			assert_equal birth_datum.case_control_flag, 'control'
			assert       birth_datum.match_confidence.blank?
			assert_equal birth_datum.sex, line['sex']
			assert_equal birth_datum.dob, Date.parse(line['dob'])

			f.close
		} } #	}
	end

	test "should test with real data file" do
		#	real data and won't be in repository
		real_data_file = "birth_datum_update_20120424.csv"
		unless File.exists?(real_data_file)
			puts
			puts "-- Real data test file does not exist. Skipping."
			return 
		end

		#	case must exist for candidate controls to be created
		s = Factory(:case_study_subject,:sex => 'M',
			:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
			:dob => Date.parse('6/1/2009'))
		Factory(:icf_master_id,:icf_master_id => '15851196C')
		s.assign_icf_master_id

		birth_datum_update = nil

		assert_difference('BirthDatum.count',33){
		assert_difference('CandidateControl.count',5){
			birth_datum_update = Factory(:birth_datum_update,
				:csv_file => File.open(real_data_file) )
			assert_not_nil birth_datum_update.csv_file_file_name
		} }
		birth_datum_update.destroy
	end

#
#	some of these test names are remnants and probably confusing
#

	test "should return a StudySubject in results for case" do
		study_subject = create_case_for_birth_datum_update
		File.open(csv_test_file_name,'w'){|f|
			f.puts csv_file_header
			f.puts csv_file_case_study_subject }
#	NOTE this is different from the subject so an exception is now created
		assert_difference('OdmsException.count',1){
		assert_difference('CandidateControl.count',0){
		assert_difference('BirthDatum.count',1){
			birth_datum_update = create_birth_datum_update_with_file
		} } }
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
				assert_equal 'birth data append',
					birth_datum.odms_exceptions.first.name
				assert_match /Unknown case_control_flag/,
					birth_datum.odms_exceptions.first.to_s
			end
		} } }
	end

	test "should create odms exception if birth datum creation fails" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('OdmsException.count',2) {
		assert_difference('CandidateControl.count',0) {
		assert_difference('BirthDatum.count',0) {
		assert_difference('BirthDatumUpdate.count',1) {
			BirthDatum.any_instance.stubs(:create_or_update).returns(false)
			birth_datum_update = Factory(:one_record_birth_datum_update)
			assert_match /Record failed to save/,
				birth_datum_update.odms_exceptions.first.to_s
			assert_match /birth_data append/,
				birth_datum_update.odms_exceptions.last.name
		} } } }
	end
#
#	These two will seemingly not really happen, but if they do,
#	I would expect them both to always happen together, logically.
#	Kinda redundant. If one record fails to save, then the count
#	should be wrong as well.
#
	test "should create odms exception if birth datum count incorrect" do
		study_subject = create_case_for_birth_datum_update
		assert_difference('OdmsException.count',1) {
		assert_difference('CandidateControl.count',1) {	#	after_create should add this
		assert_difference('BirthDatum.count',1) {	#	after_create should add this
		assert_difference('BirthDatumUpdate.count',1) {
			BirthDatumUpdate.any_instance.stubs(:birth_data_count).returns(0)
			birth_datum_update = Factory(:one_record_birth_datum_update)
			assert_match /Birth data upload validation failed: incorrect number of birth data records appended to birth_data/,
				birth_datum_update.odms_exceptions.last.to_s
			assert_match /birth_data append/,
				birth_datum_update.odms_exceptions.last.name
		} } } }
	end

protected

	def delete_all_possible_birth_datum_update_attachments
		#	BirthDatumUpdate.destroy_all
		#	either way will do the job.
		#	/bin/rm -rf test/birth_datum_update
		FileUtils.rm_rf('test/birth_datum_update')
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_birth_datum_update

end
