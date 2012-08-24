require 'test_helper'

class ScreeningDatumUpdateTest < ActiveSupport::TestCase
	include ScreeningDatumUpdateTestHelper

	assert_should_have_many(:screening_data)

	setup :turn_off_paperclip_logging
	#
	#	NOTE that paperclip attachments apparently don't get removed
	#		so we must do it on our own.  In addition, if the test
	#		fails before you do so, these files end up lying around.
	#		A bit of a pain in the butt.  So I added this explicit
	#		cleanup of the screening_datum_update csv_files.
	#		Works very nicely.
	#
	teardown :delete_all_possible_screening_datum_update_attachments

	teardown :cleanup_screening_datum_update_and_test_file	#	remove tmp/FILE.csv

	test "screening datum update factory should create screening datum update" do
		assert_difference('ScreeningDatumUpdate.count',1) {
			screening_datum_update = Factory(:screening_datum_update)
			assert_not_nil screening_datum_update.csv_file_file_name
			assert_equal   screening_datum_update.csv_file_file_name, 
				'empty_screening_datum_update_test_file.csv'
			assert_not_nil screening_datum_update.csv_file_content_type
			assert_equal screening_datum_update.csv_file_content_type,
				'text/csv'
			assert_not_nil screening_datum_update.csv_file_file_size
			assert_not_nil screening_datum_update.csv_file_updated_at
		}
	end

	test "screening datum update factory should not create screening datum" do
		assert_difference('ScreeningDatum.count',0) {	#	after_create should do nothing
			screening_datum_update = Factory(:screening_datum_update)
		}
	end

	test "empty screening datum update factory should create screening datum update" do
		assert_difference('ScreeningDatumUpdate.count',1) {
			screening_datum_update = Factory(:empty_screening_datum_update)
			assert_not_nil screening_datum_update.csv_file_file_name
			assert_equal   screening_datum_update.csv_file_file_name, 
				'empty_screening_datum_update_test_file.csv'
			assert_not_nil screening_datum_update.csv_file_content_type
			assert_equal screening_datum_update.csv_file_content_type,
				'text/csv'
			assert_not_nil screening_datum_update.csv_file_file_size
			assert_not_nil screening_datum_update.csv_file_updated_at
		}
	end

	test "empty screening datum update factory should not create screening datum" do
		assert_difference('ScreeningDatum.count',0) {	#	after_create should do nothing
			screening_datum_update = Factory(:empty_screening_datum_update)
			assert_nil screening_datum_update.screening_data.first
		}
	end

	test "one record screening datum update factory should create screening datum update" do
#	irrelevant for now
#		study_subject = create_case_for_screening_datum_update
		assert_difference('ScreeningDatumUpdate.count',1) {
			screening_datum_update = Factory(:one_record_screening_datum_update)
			assert_not_nil screening_datum_update.csv_file_file_name
			assert_equal   screening_datum_update.csv_file_file_name, 
				'one_record_screening_datum_update_test_file.csv'
			assert_not_nil screening_datum_update.csv_file_content_type
			assert_equal screening_datum_update.csv_file_content_type,
				'text/csv'
			assert_not_nil screening_datum_update.csv_file_file_size
			assert_not_nil screening_datum_update.csv_file_updated_at
		}
	end

	test "one record screening datum update factory should create screening datum" do
#	irrelevant for now
#		study_subject = create_case_for_screening_datum_update
		assert_difference('ScreeningDatum.count',1) {	#	after_create should add this
			screening_datum_update = Factory(:one_record_screening_datum_update)
			assert_not_nil screening_datum_update.screening_data.first
		}
	end

	test "should require csv_file" do
		screening_datum_update = ScreeningDatumUpdate.new
		assert !screening_datum_update.valid?
		assert  screening_datum_update.errors.include?(:csv_file)
	end

	test "should allow that attached csv_file content_type be text/plain" do
		screening_datum_update = ScreeningDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_screening_datum_update_test_file.csv', 'text/plain') )
		screening_datum_update.valid?
		assert !screening_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should allow that attached csv_file content_type be text/csv" do
		screening_datum_update = ScreeningDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_screening_datum_update_test_file.csv', 'text/csv') )
		screening_datum_update.valid?
		assert !screening_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should allow that attached csv_file content_type be application/vnd.ms-excel" do
		screening_datum_update = ScreeningDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_screening_datum_update_test_file.csv', 'application/vnd.ms-excel') )
		screening_datum_update.valid?
		assert !screening_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should require that attached csv_file be csv" do
		screening_datum_update = ScreeningDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/empty_screening_datum_update_test_file.csv', 'text/funky') )
		assert !screening_datum_update.valid?
		assert  screening_datum_update.errors.include?(:csv_file_content_type)
	end

	test "should require expected column names in csv file" do
		screening_datum_update = ScreeningDatumUpdate.new(
			:csv_file => Rack::Test::UploadedFile.new(
				'test/assets/bad_header_test_file.csv', 'text/csv') )

		assert !screening_datum_update.valid?

#		screening_datum_update.valid_csv_file_column_names
		assert  screening_datum_update.errors.include?(:csv_file)
		assert  screening_datum_update.errors.matching?(:csv_file,
			'Invalid column name .* in csv_file')
#pending 'Temporarily disabled this validation, but works manually.'
	end

	test "should create odms exception if screening datum creation fails" do
#	irrelevant for now
#		study_subject = create_case_for_screening_datum_update
		assert_difference('OdmsException.count',2) {
		assert_difference('ScreeningDatum.count',0) {
		assert_difference('ScreeningDatumUpdate.count',1) {
			ScreeningDatum.any_instance.stubs(:create_or_update).returns(false)
			screening_datum_update = Factory(:one_record_screening_datum_update)
			ScreeningDatum.any_instance.unstub(:create_or_update)
#puts screening_datum_update.odms_exceptions.class	#	crashes?
#	NoMethodError: undefined method `row' for #<String:0x00000103576fa8>
#puts screening_datum_update.odms_exceptions.length	#	same crash?
#			assert_equal 2, screening_datum_update.odms_exceptions.length
#puts screening_datum_update.odms_exceptions.count	#	works
#puts screening_datum_update.odms_exceptions.first.inspect	#	works
#puts screening_datum_update.odms_exceptions.last.inspect	#	works
			assert_match /Record failed to save/,
				screening_datum_update.odms_exceptions.first.to_s
			assert_match /Screening data upload validation failed: incorrect number of screening data records appended to screening_data/,
				screening_datum_update.odms_exceptions.last.to_s
			assert_match /screening_data append/,
				screening_datum_update.odms_exceptions.first.name
			assert_match /screening_data append/,
				screening_datum_update.odms_exceptions.last.name
		} } }
	end
#
#	These two will seemingly not really happen, but if they do,
#	I would expect them both to always happen together, logically.
#	Kinda redundant. If one record fails to save, then the count
#	should be wrong as well.
#
	test "should create odms exception if screening datum count incorrect" do
#	irrelevant for now
#		study_subject = create_case_for_screening_datum_update
		assert_difference('OdmsException.count',2) {# this one, plus "No subject w/icfmasterid
		assert_difference('ScreeningDatum.count',1) {	#	after_create should add this
		assert_difference('ScreeningDatumUpdate.count',1) {
			ScreeningDatumUpdate.any_instance.stubs(:screening_data_count).returns(0)
			screening_datum_update = Factory(:one_record_screening_datum_update)
			assert_equal 1, screening_datum_update.odms_exceptions.length
			assert_match /Screening data upload validation failed: incorrect number of screening data records appended to screening_data/,
				screening_datum_update.odms_exceptions.last.to_s
			assert_match /screening_data append/,
				screening_datum_update.odms_exceptions.last.name
		} } }
	end




	test "should test with real data file" do
		#	real data and won't be in repository
		real_data_file = "screening_datum_update_20120822.csv"
		unless File.exists?(real_data_file)
			puts
			puts "-- Real data test file does not exist. Skipping."
			return 
		end

#		#	case must exist for candidate controls to be created
#		s = Factory(:case_study_subject,:sex => 'M',
#			:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
#			:dob => Date.parse('6/1/2009'))
#		Factory(:icf_master_id,:icf_master_id => '15851196C')
#		s.assign_icf_master_id

		#	Create subjects to update based on the file
		#	Nothing should match so could actually test the other counts
		(f=CSV.open( real_data_file, 'rb',{
						:headers => true })).each do |line|
			Factory(:study_subject,:icf_master_id => line['icf_master_id'])
		end

		screening_datum_update = nil

#		assert_difference('OperationalEvent.count',166){
		assert_difference("OperationalEventType['dataconflict']"<<
			".operational_events.count",25){
		assert_difference("OperationalEventType['datachanged']"<<
			".operational_events.count",94){
		assert_difference("OperationalEventType['screener_complete']"<<
			".operational_events.count",47){
		assert_difference('OdmsException.count',0){
		assert_difference('ScreeningDatum.count',47){
			screening_datum_update = Factory(:screening_datum_update,
				:csv_file => File.open(real_data_file) )
			assert_not_nil screening_datum_update.csv_file_file_name
		} } } } }
		screening_datum_update.destroy
	end




#	what about other creation failures

	test "should do what if creating odms exception fails" do
pending	#	bang or no bang?	#	if this happens, we've got problems
	end

	test "should do what if creating operational event fails" do
pending	#	bang or no bang?	#	if this happens, we've got problems
	end

	test "should do what if updating study subject fails" do
pending	#	bang or no bang?
	end




protected

	def delete_all_possible_screening_datum_update_attachments
		#	ScreeningDatumUpdate.destroy_all
		#	either way will do the job.
		#	/bin/rm -rf test/screening_datum_update
		FileUtils.rm_rf('test/screening_datum_update')
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_screening_datum_update

end
