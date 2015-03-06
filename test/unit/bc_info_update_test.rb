require 'test_helper'

class BcInfoUpdateTest < ActiveSupport::TestCase

	teardown :cleanup_bc_info_update_and_test_file	#	remove tmp/FILE.csv (csv_test_file_name)

	test "should create bc info update" do
		bc_info_update = BcInfoUpdate.new('test/assets/empty_bc_info_update_test_file.csv')
		assert_not_nil bc_info_update.csv_file
		assert_equal   bc_info_update.csv_file, 'test/assets/empty_bc_info_update_test_file.csv'
	end

	test "should have 4 different possible expected columns" do
		assert_equal 4, BcInfoUpdate.expected_columns.length
	end

	BcInfoUpdate.expected_columns.each_with_index do |a,i|

		test "should allow columns set #{i}" do
			CSV.open(csv_test_file_name,'w'){|c| c << BcInfoUpdate.expected_columns[i] }
			bc_info_update = BcInfoUpdate.new(csv_test_file_name)
			assert bc_info_update.status.blank?
		end

	end

	test "should not allow unexpected column names" do
		CSV.open(csv_test_file_name,'w'){|c| c << %w( col1 col2 col3 ) }
		bc_info_update = BcInfoUpdate.new(csv_test_file_name)
		assert_match /unexpected column names/, bc_info_update.status
		#	returns without parsing
	end

	test "should archive" do
		FileUtils.stubs(:mkdir_p).returns(true) 
		File.stubs(:exists?).returns(false)
		FileUtils.stubs(:move).returns(true)
		bc_info_update = BcInfoUpdate.new('test/assets/empty_bc_info_update_test_file.csv',:verbose => true)
		bc_info_update.archive
	end




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

	test "should test with real data file" do
		#	real data and won't be in repository
		real_data_file = "data/bc_info_20120822.csv"
		unless File.exists?(real_data_file)
			puts
			puts "-- Real data test file does not exist. Skipping."
		else

			#	Create subjects to update based on the file
			#	Nothing should match so could actually test the other counts
			assert_difference('StudySubject.count',94) {
				(f=CSV.open( real_data_file, 'rb',{
						:headers => true })).each { |line|
					subject = FactoryGirl.create(:study_subject,:icf_master_id => line['icf_master_id'])
	
					#	need the mother to exist to create an operational event
					subject.create_mother

			} }

			bc_info_update = nil

			assert_difference("OperationalEventType['datachanged']"<<
				".operational_events.count",94){
			assert_difference("OperationalEventType['screener_complete']"<<
				".operational_events.count",47){
				bc_info_update = BcInfoUpdate.new( real_data_file )
				assert_not_nil bc_info_update.csv_file
			} }
		end
	end

	test "should require csv_file to exist" do
pending
	end


#	what about other creation failures

	test "should do what if creating operational event fails" do
pending	#	bang or no bang?	#	if this happens, we've got problems
	end

	test "should do what if updating study subject fails" do
pending	#	bang or no bang?
	end




protected

	def create_test_file_and_bc_info_update(options={})
		create_bc_info_update_test_file(options)
		bc_info_update = create_bc_info_update_with_file
	end

	def create_bc_info_update_with_file
		bc_info_update = BcIfoUpdate.new(csv_test_file_name)
		assert_not_nil bc_info_update.csv_file
		bc_info_update
	end

	def cleanup_bc_info_update_and_test_file(bc_info_update=nil)
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
