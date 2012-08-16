require 'test_helper'

class BirthDatumUpdatesControllerTest < ActionController::TestCase
	include BirthDatumUpdateTestHelper

	#
	#	NOTE that paperclip attachments apparently don't get removed
	#		so we must do it on our own.  In addition, if the test
	#		fails before you do so, these files end up lying around.
	#		A bit of a pain in the butt.  So I added this explicit
	#		cleanup of the birth_datum_update csv_files.
	#		Works very nicely.
	#
	
	#	setup :turn_off_paperclip_logging

	teardown :delete_all_possible_birth_datum_update_attachments

	teardown :cleanup_birth_datum_update_and_test_file	#	remove tmp/FILE.csv

	ASSERT_ACCESS_OPTIONS = {
		:model => 'BirthDatumUpdate',
		:actions => [:new,:create,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_birth_datum_update
	}
	#	BirthDatumUpdate have no attributes other than the csv_file
	#	so need to add the updated_at to force a difference
	#	on update.
	def factory_attributes(options={})
		Factory.attributes_for(:birth_datum_update,{
			:updated_at => Time.now }.merge(options))
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	site_administrators.each do |cu|

		test "should create with csv_file attachment and #{cu} login" do
			login_as send(cu)
			assert_difference('CandidateControl.count',0) {
			assert_difference('BirthDatum.count',0) {
			assert_difference('BirthDatumUpdate.count',1) {
				post :create, :birth_datum_update => factory_attributes
			} } }
			assert_not_nil flash[:notice]
			assert_not_nil assigns(:birth_datum_update).csv_file_file_name
			assert_not_nil assigns(:birth_datum_update).csv_file_content_type
			assert_not_nil assigns(:birth_datum_update).csv_file_file_size
			assert_not_nil assigns(:birth_datum_update).csv_file_updated_at
		end

		test "should create with csv_file attachment control record and #{cu} login" do
			login_as send(cu)
			create_case_for_birth_datum_update
			assert_difference('CandidateControl.count',1) {	#	may depend on record content!
			assert_difference('BirthDatum.count',1) {
			assert_difference('BirthDatumUpdate.count',1) {
				post :create, :birth_datum_update => Factory.attributes_for(
					:one_record_birth_datum_update )
			} } }
			assert_not_nil flash[:notice]
			assert_not_nil assigns(:birth_datum_update).csv_file_file_name
			assert_not_nil assigns(:birth_datum_update).csv_file_content_type
			assert_not_nil assigns(:birth_datum_update).csv_file_file_size
			assert_not_nil assigns(:birth_datum_update).csv_file_updated_at
		end

#	should I allow editting the file?		I don't think so as it is parsed after_CREATE
#
#		test "should update with csv_file attachment and #{cu} login" do
#			login_as send(cu)
#			birth_datum_update = Factory(:birth_datum_update)
#			assert_difference('BirthDatumUpdate.count',0) {
#				put :update, :id => birth_datum_update.id, 
#					:birth_datum_update => factory_attributes
#			}
#			birth_datum_update.reload
#			assert_not_nil flash[:notice]
#			assert_not_nil birth_datum_update.csv_file_file_name
#			assert File.exists?(birth_datum_update.csv_file.path)
#			assert_not_nil birth_datum_update.csv_file_content_type
#			assert_not_nil birth_datum_update.csv_file_file_size
#			assert_not_nil birth_datum_update.csv_file_updated_at
#		end

#	should I allow destroying?

		test "should destroy with csv_file attachment and #{cu} login" do
			login_as send(cu)
			birth_datum_update = Factory(:birth_datum_update)
			assert_difference('BirthDatumUpdate.count',-1) {
				delete :destroy, :id => birth_datum_update.id
			}
		end

#	PARSING IS GOING TO BE AUTOMATIC
#
#	perhaps move these tests into the create action


#		test "should parse with #{cu} login" do
#			login_as send(cu)
#			create_case_for_birth_datum_update
#			birth_datum_update = create_test_file_and_birth_datum_update
#			assert_difference('CandidateControl.count',1){
#				post :parse, :id => birth_datum_update.id
#			}
#			assert assigns(:csv_lines)
#			assert assigns(:results)
#			assert_template 'parse'
#		end
#
#		test "should parse with #{cu} login and empty csv_file" do
#			login_as send(cu)
#			birth_datum_update = Factory(:empty_birth_datum_update)
#			assert_difference('CandidateControl.count',0){
#				post :parse, :id => birth_datum_update.id
#			}
#			assert_nil flash[:error]
#			assert assigns(:csv_lines)
#			assert assigns(:results)
#			assert_template 'parse'
#		end
#
#		test "should parse with #{cu} login and missing csv_file" do
#			login_as send(cu)
#			birth_datum_update = Factory(:birth_datum_update)
#			File.delete(birth_datum_update.csv_file.path)
#			assert_difference('CandidateControl.count',0){
#				post :parse, :id => birth_datum_update.id
#			}
#			assert_not_nil flash[:error]
#			assert_redirected_to assigns(:birth_datum_update)
#		end

		test "should parse with #{cu} login and real csv_file" do
			#	real data and won't be in repository
			real_data_file = "birth_datum_update_20120424.csv"
			unless File.exists?(real_data_file)
				puts
				puts "-- Real data test file does not exist. Skipping."
				return 
			end
			login_as send(cu)

#			#	minimal semi-real case creation
#			s1 = Factory(:case_study_subject,:sex => 'F',
#				:first_name => 'FakeFirst1',:last_name => 'FakeLast1', 
#				:dob => Date.parse('10/16/1977'))
#			#	s1 has no icf_master_id, so should be ignored
#	
#			s2 = Factory(:case_study_subject,:sex => 'F',
#				:first_name => 'FakeFirst2',:last_name => 'FakeLast2', 
#				:dob => Date.parse('9/21/1988'))
#			Factory(:icf_master_id,:icf_master_id => '48882638A')
#			s2.assign_icf_master_id
#	
			s = Factory(:case_study_subject,:sex => 'M',
				:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
				:dob => Date.parse('6/1/2009'))
			Factory(:icf_master_id,:icf_master_id => '15851196C')	#	match file content
			s.assign_icf_master_id
	
			assert_difference('BirthDatum.count',33){
			assert_difference('CandidateControl.count',5){
				post :create, :birth_datum_update => factory_attributes(
					:csv_file => Rack::Test::UploadedFile.new( 
						real_data_file, 'text/csv') )
			} }


#			birth_datum_update = Factory(:birth_datum_update,
#				:csv_file => File.open('test-livebirthdata_011912.csv') )
#			assert_not_nil birth_datum_update.csv_file_file_name
#	
#			#	35 lines - 1 header - 3 cases = 31
#			assert_difference('CandidateControl.count',31){
#				post :parse, :id => birth_datum_update.id
#			}
#			assert assigns(:csv_lines)
#			assert assigns(:results)
#
#			assert assigns(:results)[0].is_a?(String)
#			assert_equal assigns(:results)[0],
#				"Could not find study_subject with master_id [no ID assigned]"
#			assert assigns(:results)[1].is_a?(StudySubject)
#			assert assigns(:results)[2].is_a?(StudySubject)
#			assigns(:results).each { |r|
#				if r.is_a?(CandidateControl) and r.new_record?
#					puts r.inspect
#					puts r.errors.full_messages.to_sentence
#				end
#			}

#			birth_datum_update.destroy
		end


		test "should NOT create with #{cu} login and stray csv quote" do
			login_as send(cu)
#			File.open(csv_test_file_name,'w'){|f|
#				f.puts csv_file_header
#				f.puts stray_csv_quote_line }
			create_stray_quote_csv_file
			assert_difference('BirthDatum.count',0){
			assert_difference('CandidateControl.count',0){
				post :create, :birth_datum_update => factory_attributes(
					:csv_file => Rack::Test::UploadedFile.new( 
						csv_test_file_name, 'text/csv') )
#						'test/assets/stray_quote_test_file.csv', 'text/csv') )
			} }
			assert_not_nil flash[:error]
			assert_match "CSV error.<br/>", flash[:error]
pending 'Pending as still need to reproduce this actual error'
		end

		test "should NOT create with #{cu} login and unclosed csv quote" do
			login_as send(cu)
#			File.open(csv_test_file_name,'w'){|f|
#				f.puts csv_file_header
#				f.puts unclosed_csv_quote_line }
			create_unclosed_quote_csv_file
			assert_difference('BirthDatum.count',0){
			assert_difference('CandidateControl.count',0){
				post :create, :birth_datum_update => factory_attributes(
					:csv_file => Rack::Test::UploadedFile.new( 
						csv_test_file_name, 'text/csv') )
#						'test/assets/unclosed_quote_test_file.csv', 'text/csv') )
			} }
			assert_not_nil flash[:error]
			assert_match "CSV error.<br/>Unclosed quoted field", flash[:error]
		end

		test "should NOT create with #{cu} login and illegal csv quote" do
			login_as send(cu)
#			File.open(csv_test_file_name,'w'){|f|
#				f.puts csv_file_header
#				f.puts illegal_csv_quote_line }
			create_illegal_quote_csv_file
			assert_difference('BirthDatum.count',0){
			assert_difference('CandidateControl.count',0){
				post :create, :birth_datum_update => factory_attributes(
					:csv_file => Rack::Test::UploadedFile.new( 
						csv_test_file_name, 'text/csv') )
#						'test/assets/illegal_quote_test_file.csv', 'text/csv') )
			} }
			assert_not_nil flash[:error]
			assert_match "CSV error.<br/>Illegal quoting", flash[:error]
		end

	end

	non_site_administrators.each do |cu|

#		test "should not parse with #{cu} login" do
#			login_as send(cu)
#			create_case_for_birth_datum_update
#			birth_datum_update = create_test_file_and_birth_datum_update
#			assert_difference('CandidateControl.count',0){
#				post :parse, :id => birth_datum_update.id
#			}
#		end

	end

#	test "should not parse without login" do
#		create_case_for_birth_datum_update
#		birth_datum_update = create_test_file_and_birth_datum_update
#		assert_difference('CandidateControl.count',0){
#			post :parse, :id => birth_datum_update.id
#		}
#	end

protected

	def delete_all_possible_birth_datum_update_attachments
		#	/bin/rm -rf test/birth_datum_update
		FileUtils.rm_rf('test/birth_datum_update')
	end

end
