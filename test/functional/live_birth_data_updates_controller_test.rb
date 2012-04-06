require 'test_helper'

class LiveBirthDataUpdatesControllerTest < ActionController::TestCase
	include LiveBirthDataUpdateTestHelper

	#
	#	NOTE that paperclip attachments apparently don't get removed
	#		so we must do it on our own.  In addition, if the test
	#		fails before you do so, these files end up lying around.
	#		A bit of a pain in the butt.  So I added this explicit
	#		cleanup of the live_birth_data_update csv_files.
	#		Works very nicely.
	#
	
	#	setup :turn_off_paperclip_logging

	teardown :delete_all_possible_live_birth_data_update_attachments
	def delete_all_possible_live_birth_data_update_attachments
		#	/bin/rm -rf test/live_birth_data_update
		FileUtils.rm_rf('test/live_birth_data_update')
	end

	ASSERT_ACCESS_OPTIONS = {
		:model => 'LiveBirthDataUpdate',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_live_birth_data_update
	}
	#	LiveBirthDataUpdate have no attributes other than the csv_file
	#	so need to add the updated_at to force a difference
	#	on update.
	def factory_attributes(options={})
		Factory.attributes_for(:live_birth_data_update,{
			:updated_at => Time.now }.merge(options))
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	site_administrators.each do |cu|

		test "should create with csv_file attachment and #{cu} login" do
			login_as send(cu)
#			create_live_birth_data_update_test_file
			assert_difference('LiveBirthDataUpdate.count',1) {
				post :create, :live_birth_data_update => factory_attributes
#					:csv_file => Rack::Test::UploadedFile.new(csv_test_file_name)
#				}
			}
			assert_not_nil flash[:notice]
			assert_not_nil assigns(:live_birth_data_update).csv_file_file_name
#			assert_equal   assigns(:live_birth_data_update).csv_file_file_name, csv_test_file_name
			assert_not_nil assigns(:live_birth_data_update).csv_file_content_type
			assert_not_nil assigns(:live_birth_data_update).csv_file_file_size
			assert_not_nil assigns(:live_birth_data_update).csv_file_updated_at
		end

#	should I allow editting the file?

		test "should update with csv_file attachment and #{cu} login" do
			login_as send(cu)
			live_birth_data_update = Factory(:live_birth_data_update)
#			assert_nil live_birth_data_update.csv_file_file_name
#			create_live_birth_data_update_test_file
			assert_difference('LiveBirthDataUpdate.count',0) {
				put :update, :id => live_birth_data_update.id, 
					:live_birth_data_update => factory_attributes
#					:csv_file => Rack::Test::UploadedFile.new(csv_test_file_name)
#				}
			}
			live_birth_data_update.reload
			assert_not_nil flash[:notice]
			assert_not_nil live_birth_data_update.csv_file_file_name
#			assert_equal   live_birth_data_update.csv_file_file_name, csv_test_file_name
			assert File.exists?(live_birth_data_update.csv_file.path)
			assert_not_nil live_birth_data_update.csv_file_content_type
			assert_not_nil live_birth_data_update.csv_file_file_size
			assert_not_nil live_birth_data_update.csv_file_updated_at
		end

#	should I allow destroying?

		test "should destroy with csv_file attachment and #{cu} login" do
			login_as send(cu)
			live_birth_data_update = Factory(:live_birth_data_update)
			assert_difference('LiveBirthDataUpdate.count',-1) {
				delete :destroy, :id => live_birth_data_update.id
			}
		end

		test "should parse with #{cu} login" do
			login_as send(cu)
			create_case_for_live_birth_data_update
			live_birth_data_update = create_test_file_and_live_birth_data_update
			assert_difference('CandidateControl.count',1){
				post :parse, :id => live_birth_data_update.id
			}
			assert assigns(:csv_lines)
			assert assigns(:results)
			assert_template 'parse'
			cleanup_live_birth_data_update_and_test_file
		end

		test "should parse with #{cu} login and empty csv_file" do
			login_as send(cu)
			live_birth_data_update = Factory(:empty_live_birth_data_update)
			assert_difference('CandidateControl.count',0){
				post :parse, :id => live_birth_data_update.id
			}
			assert_nil flash[:error]
			assert assigns(:csv_lines)
			assert assigns(:results)
			assert_template 'parse'
		end

		test "should parse with #{cu} login and missing csv_file" do
			login_as send(cu)
			live_birth_data_update = Factory(:live_birth_data_update)
			File.delete(live_birth_data_update.csv_file.path)
			assert_difference('CandidateControl.count',0){
				post :parse, :id => live_birth_data_update.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to assigns(:live_birth_data_update)
		end

		test "should parse with #{cu} login and real csv_file" do
			#	real data and won't be in repository
			unless File.exists?('test-livebirthdata_011912.csv')
				puts
				puts "-- Real data test file does not exist. Skipping."
				return 
			end
			login_as send(cu)

			#	minimal semi-real case creation
			s1 = Factory(:case_study_subject,:sex => 'F',
				:first_name => 'FakeFirst1',:last_name => 'FakeLast1', 
				:dob => Date.parse('10/16/1977'))
			#	s1 has no icf_master_id, so should be ignored
	
			s2 = Factory(:case_study_subject,:sex => 'F',
				:first_name => 'FakeFirst2',:last_name => 'FakeLast2', 
				:dob => Date.parse('9/21/1988'))
			Factory(:icf_master_id,:icf_master_id => '48882638A')
			s2.assign_icf_master_id
	
			s3 = Factory(:case_study_subject,:sex => 'M',
				:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
				:dob => Date.parse('6/1/2009'))
			Factory(:icf_master_id,:icf_master_id => '16655682G')
			s3.assign_icf_master_id
	
			live_birth_data_update = Factory(:live_birth_data_update,
				:csv_file => File.open('test-livebirthdata_011912.csv') )
			assert_not_nil live_birth_data_update.csv_file_file_name
	
			#	35 lines - 1 header - 3 cases = 31
			assert_difference('CandidateControl.count',31){
				post :parse, :id => live_birth_data_update.id
			}
			assert assigns(:csv_lines)
			assert assigns(:results)

			assert assigns(:results)[0].is_a?(String)
			assert_equal assigns(:results)[0],
				"Could not find study_subject with masterid [no ID assigned]"
			assert assigns(:results)[1].is_a?(StudySubject)
			assert assigns(:results)[2].is_a?(StudySubject)
			assigns(:results).each { |r|
				if r.is_a?(CandidateControl) and r.new_record?
					puts r.inspect
					puts r.errors.full_messages.to_sentence
				end
			}
			live_birth_data_update.destroy
		end

	end

	non_site_administrators.each do |cu|

		test "should not parse with #{cu} login" do
			login_as send(cu)
			create_case_for_live_birth_data_update
			live_birth_data_update = create_test_file_and_live_birth_data_update
			assert_difference('CandidateControl.count',0){
				post :parse, :id => live_birth_data_update.id
			}
			cleanup_live_birth_data_update_and_test_file
		end

	end

	test "should not parse without login" do
		create_case_for_live_birth_data_update
		live_birth_data_update = create_test_file_and_live_birth_data_update
		assert_difference('CandidateControl.count',0){
			post :parse, :id => live_birth_data_update.id
		}
		cleanup_live_birth_data_update_and_test_file
	end

end
