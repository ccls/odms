require 'test_helper'

class BcInfoUpdateTest < ActiveSupport::TestCase
#
#	assert_should_have_many(:screening_data)
#
#	setup :turn_off_paperclip_logging
#	#
#	#	NOTE that paperclip attachments apparently don't get removed
#	#		so we must do it on our own.  In addition, if the test
#	#		fails before you do so, these files end up lying around.
#	#		A bit of a pain in the butt.  So I added this explicit
#	#		cleanup of the bc_info_update csv_files.
#	#		Works very nicely.
#	#
#	teardown :delete_all_possible_bc_info_update_attachments
#
#	teardown :cleanup_bc_info_update_and_test_file	#	remove tmp/FILE.csv
#
#	test "bc info update factory should create bc info update" do
#		assert_difference('BcInfoUpdate.count',1) {
#			bc_info_update = FactoryGirl.create(:bc_info_update)
#			assert_not_nil bc_info_update.csv_file_file_name
#			assert_equal   bc_info_update.csv_file_file_name, 
#				'empty_bc_info_update_test_file.csv'
#			assert_not_nil bc_info_update.csv_file_content_type
#			assert_equal bc_info_update.csv_file_content_type,
#				'text/csv'
#			assert_not_nil bc_info_update.csv_file_file_size
#			assert_not_nil bc_info_update.csv_file_updated_at
#		}
#	end
#
#	test "bc info update factory should not create bc info" do
#		assert_difference('BcInfo.count',0) {	#	after_create should do nothing
#			bc_info_update = FactoryGirl.create(:bc_info_update)
#		}
#	end
#
#	test "empty bc info update factory should create bc info update" do
#		assert_difference('BcInfoUpdate.count',1) {
#			bc_info_update = FactoryGirl.create(:empty_bc_info_update)
#			assert_not_nil bc_info_update.csv_file_file_name
#			assert_equal   bc_info_update.csv_file_file_name, 
#				'empty_bc_info_update_test_file.csv'
#			assert_not_nil bc_info_update.csv_file_content_type
#			assert_equal bc_info_update.csv_file_content_type,
#				'text/csv'
#			assert_not_nil bc_info_update.csv_file_file_size
#			assert_not_nil bc_info_update.csv_file_updated_at
#		}
#	end
#
#	test "empty bc info update factory should not create bc info" do
#		assert_difference('BcInfo.count',0) {	#	after_create should do nothing
#			bc_info_update = FactoryGirl.create(:empty_bc_info_update)
#			assert_nil bc_info_update.screening_data.first
#		}
#	end
#
#	test "one record bc info update factory should create bc info update" do
##	irrelevant for now
##		study_subject = create_case_for_bc_info_update
#		assert_difference('BcInfoUpdate.count',1) {
#			bc_info_update = FactoryGirl.create(:one_record_bc_info_update)
#			assert_not_nil bc_info_update.csv_file_file_name
#			assert_equal   bc_info_update.csv_file_file_name, 
#				'one_record_bc_info_update_test_file.csv'
#			assert_not_nil bc_info_update.csv_file_content_type
#			assert_equal bc_info_update.csv_file_content_type,
#				'text/csv'
#			assert_not_nil bc_info_update.csv_file_file_size
#			assert_not_nil bc_info_update.csv_file_updated_at
#		}
#	end
#
#	test "one record bc info update factory should create bc info" do
#	irrelevant for now
#		study_subject = create_case_for_bc_info_update
#		assert_difference('BcInfo.count',1) {	#	after_create should add this
#			bc_info_update = FactoryGirl.create(:one_record_bc_info_update)
#			assert_not_nil bc_info_update.screening_data.first
#		}
#	end
#
#	test "should require csv_file" do
#		bc_info_update = BcInfoUpdate.new
#		assert !bc_info_update.valid?
#		assert  bc_info_update.errors.include?(:csv_file)
#	end
#
#	test "should allow that attached csv_file content_type be text/plain" do
#		bc_info_update = BcInfoUpdate.new(
#			:csv_file => Rack::Test::UploadedFile.new(
#				'test/assets/empty_bc_info_update_test_file.csv', 'text/plain') )
#		bc_info_update.valid?
#		assert !bc_info_update.errors.include?(:csv_file_content_type)
#	end
#
#	test "should allow that attached csv_file content_type be text/csv" do
#		bc_info_update = BcInfoUpdate.new(
#			:csv_file => Rack::Test::UploadedFile.new(
#				'test/assets/empty_bc_info_update_test_file.csv', 'text/csv') )
#		bc_info_update.valid?
#		assert !bc_info_update.errors.include?(:csv_file_content_type)
#	end
#
#	test "should allow that attached csv_file content_type be application/vnd.ms-excel" do
#		bc_info_update = BcInfoUpdate.new(
#			:csv_file => Rack::Test::UploadedFile.new(
#				'test/assets/empty_bc_info_update_test_file.csv', 'application/vnd.ms-excel') )
#		bc_info_update.valid?
#		assert !bc_info_update.errors.include?(:csv_file_content_type)
#	end
#
#	test "should require that attached csv_file be csv" do
#		bc_info_update = BcInfoUpdate.new(
#			:csv_file => Rack::Test::UploadedFile.new(
#				'test/assets/empty_bc_info_update_test_file.csv', 'text/funky') )
#		assert !bc_info_update.valid?
#		assert  bc_info_update.errors.include?(:csv_file_content_type)
#	end
#
#	test "should require expected column names in csv file" do
#		bc_info_update = BcInfoUpdate.new(
#			:csv_file => Rack::Test::UploadedFile.new(
#				'test/assets/bad_header_test_file.csv', 'text/csv') )
#
#		assert !bc_info_update.valid?
#
##		bc_info_update.valid_csv_file_column_names
#		assert  bc_info_update.errors.include?(:csv_file)
#		assert  bc_info_update.errors.matching?(:csv_file,
#			'Invalid column name .* in csv_file')
##pending 'Temporarily disabled this validation, but works manually.'
#	end
#
#	test "should create odms exception if bc info creation fails" do
##	irrelevant for now
##		study_subject = create_case_for_bc_info_update
#		assert_difference('OdmsException.count',2) {
#		assert_difference('BcInfo.count',0) {
#		assert_difference('BcInfoUpdate.count',1) {
#			BcInfo.any_instance.stubs(:create_or_update).returns(false)
#			bc_info_update = FactoryGirl.create(:one_record_bc_info_update)
#			BcInfo.any_instance.unstub(:create_or_update)
##puts bc_info_update.odms_exceptions.class	#	crashes?
##	NoMethodError: undefined method `row' for #<String:0x00000103576fa8>
##puts bc_info_update.odms_exceptions.length	#	same crash?
##			assert_equal 2, bc_info_update.odms_exceptions.length
##puts bc_info_update.odms_exceptions.count	#	works
##puts bc_info_update.odms_exceptions.first.inspect	#	works
##puts bc_info_update.odms_exceptions.last.inspect	#	works
#			assert_match /Record failed to save/,
#				bc_info_update.odms_exceptions.first.to_s
#			assert_match /Screening data upload validation failed: incorrect number of screening data records appended to screening_data/,
#				bc_info_update.odms_exceptions.last.to_s
#			assert_match /screening_data append/,
#				bc_info_update.odms_exceptions.first.name
#			assert_match /screening_data append/,
#				bc_info_update.odms_exceptions.last.name
#		} } }
#	end
##
##	These two will seemingly not really happen, but if they do,
##	I would expect them both to always happen together, logically.
##	Kinda redundant. If one record fails to save, then the count
##	should be wrong as well.
##
#	test "should create odms exception if bc info count incorrect" do
##	irrelevant for now
##		study_subject = create_case_for_bc_info_update
#		assert_difference('OdmsException.count',2) {# this one, plus "No subject w/icfmasterid
#		assert_difference('BcInfo.count',1) {	#	after_create should add this
#		assert_difference('BcInfoUpdate.count',1) {
#			BcInfoUpdate.any_instance.stubs(:screening_data_count).returns(0)
#			bc_info_update = FactoryGirl.create(:one_record_bc_info_update)
#			assert_equal 1, bc_info_update.odms_exceptions.length
#			assert_match /Screening data upload validation failed: incorrect number of screening data records appended to screening_data/,
#				bc_info_update.odms_exceptions.last.to_s
#			assert_match /screening_data append/,
#				bc_info_update.odms_exceptions.last.name
#		} } }
#	end




	test "should test with real data file" do
		#	real data and won't be in repository
		real_data_file = "screening_data/screening_datum_update_20120822.csv"
		unless File.exists?(real_data_file)
			puts
			puts "-- Real data test file does not exist. Skipping."
			return 
		end

#		#	case must exist for candidate controls to be created
#		s = FactoryGirl.create(:case_study_subject,:sex => 'M',
#			:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
#			:dob => Date.parse('6/1/2009'))
#		FactoryGirl.create(:icf_master_id,:icf_master_id => '15851196C')
#		s.assign_icf_master_id

		#	Create subjects to update based on the file
		#	Nothing should match so could actually test the other counts
		(f=CSV.open( real_data_file, 'rb',{
						:headers => true })).each do |line|
			FactoryGirl.create(:study_subject,:icf_master_id => line['icf_master_id'])
		end

		bc_info_update = nil

#		assert_difference('OperationalEvent.count',166){
		assert_difference("OperationalEventType['dataconflict']"<<
			".operational_events.count",25){
		assert_difference("OperationalEventType['datachanged']"<<
			".operational_events.count",94){
		assert_difference("OperationalEventType['screener_complete']"<<
			".operational_events.count",47){
		assert_difference('OdmsException.count',0){
#		assert_difference('BcInfo.count',47){
#			bc_info_update = FactoryGirl.create(:bc_info_update,
#				:csv_file => File.open(real_data_file) )
#			assert_not_nil bc_info_update.csv_file_file_name
			bc_info_update = BcInfoUpdate.new( real_data_file )
			assert_not_nil bc_info_update.csv_file
			assert_not_nil bc_info_update.log
		} } } } #}
		bc_info_update.destroy
	end


	test "should require csv_file to exist" do
pending
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

#	def delete_all_possible_bc_info_update_attachments
#		#	BcInfoUpdate.destroy_all
#		#	either way will do the job.
#		#	/bin/rm -rf test/bc_info_update
#		FileUtils.rm_rf('test/bc_info_update')
#	end

	def create_test_file_and_bc_info_update(options={})
		create_bc_info_update_test_file(options)
		bc_info_update = create_bc_info_update_with_file
	end

	def create_bc_info_update_with_file
#		bc_info_update = FactoryGirl.create(:bc_info_update,
#			:csv_file => File.open(csv_test_file_name) )
#		assert_not_nil bc_info_update.csv_file_file_name
		bc_info_update = BcIfoUpdate.new(csv_test_file_name)
		assert_not_nil bc_info_update.csv_file
		bc_info_update
	end

#
#	No longer necessary
#	Actually, should probably remove the source file.
#
	def cleanup_bc_info_update_and_test_file(bc_info_update=nil)
#		if bc_info_update
#			bc_info_update_file = bc_info_update.csv_file.path
#			#	explicit destroy to remove attachment
#			bc_info_update.destroy	
#			unless bc_info_update_file.blank?
#				assert !File.exists?(bc_info_update_file)
#			end
#			if File.exists?("test/bc_info_update/#{bc_info_update.id}") &&
#				File.directory?("test/bc_info_update/#{bc_info_update.id}")
#				Dir.delete("test/bc_info_update/#{bc_info_update.id}")
#			end
#		end
		if File.exists?(csv_test_file_name)
			#	explicit delete to remove test file
			File.delete(csv_test_file_name)	
		end
		assert !File.exists?(csv_test_file_name)
	end

#	def create_case_for_bc_info_update
#		icf_master_id = FactoryGirl.create(:icf_master_id,:icf_master_id => '12345FAKE')
#		study_subject = FactoryGirl.create(:complete_case_study_subject)
#		study_subject.assign_icf_master_id
#		assert_equal '12345FAKE', study_subject.icf_master_id
#		study_subject
#	end



#	def csv_file_header_array
#		BcInfoUpdate.expected_column_names					#	WILL FAIL
#	end
#
#	def csv_file_header
#		csv_file_header_array.collect{|s|"\"#{s}\""}.join(',')
#	end



#	def csv_file_unknown(options={})
#		c = unknown_subject_hash.merge(options)
#		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
#	end
#
#	def csv_file_case_study_subject(options={})
#		c = case_subject_hash.merge(options)
#		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
#	end
#
#	def csv_file_control(options={})
#		c = control_subject_hash.merge(options)
#		csv_file_header_array.collect{|s|"\"#{c[s.to_sym]}\""}.join(',')
#	end
#
#	def create_bc_info_update_test_file(options={})
#		File.open(csv_test_file_name,'w'){|f|
#			f.puts csv_file_header
#			f.puts csv_file_case_study_subject
#			f.puts csv_file_control(options) }
#	end
#
#	#	just enough for no exceptions
#	def unknown_subject_hash
#		FactoryGirl.attributes_for(:screening_datum,
#			:master_id => '12345FAKE' )
#	end
#
#	def case_subject_hash
#		FactoryGirl.attributes_for(:case_screening_datum,
#			:master_id => '12345FAKE' )
#	end
#
#	def control_subject_hash
#		FactoryGirl.attributes_for(:control_screening_datum,
#			:master_id => '12345FAKE' )
#	end

	#	shouldn't be called test_... as makes it a test method!
	def csv_test_file_name
		"tmp/bc_info_update_test_file.csv"
	end

end
