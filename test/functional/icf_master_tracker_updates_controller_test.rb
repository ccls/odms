require 'test_helper'

class IcfMasterTrackerUpdatesControllerTest < ActionController::TestCase
	include IcfMasterTrackerUpdateTestHelper

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IcfMasterTrackerUpdate',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_icf_master_tracker_update
	}
	#	IcfMasterTrackerUpdate have no attributes other than the csv_file
	#	so need to add the updated_at to force a difference
	#	on update.
	def factory_attributes(options={})
		Factory.attributes_for(:icf_master_tracker_update,{
			:updated_at => Time.now }.merge(options))
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login
#	assert_access_with_https
#	assert_no_access_with_http

	site_administrators.each do |cu|

		test "should create with csv_file attachment and #{cu} login" do
			login_as send(cu)
			create_icf_master_tracker_update_test_file
			assert_difference('IcfMasterTrackerUpdate.count',1) {
				post :create, :icf_master_tracker_update => {
					:csv_file => Rack::Test::UploadedFile.new(csv_test_file_name)
				}
			}
			assigns(:icf_master_tracker_update).reload
			assert_not_nil flash[:notice]
			assert_nil     flash[:error]
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_file_name
			assert_equal   assigns(:icf_master_tracker_update).csv_file_file_name, csv_test_file_name
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_content_type
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_file_size
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_updated_at
			cleanup_icf_master_tracker_update_and_test_file(assigns(:icf_master_tracker_update))
		end

#	should I allow editting the file?

		test "should update with csv_file attachment and #{cu} login" do
			login_as send(cu)
			icf_master_tracker_update = Factory(:icf_master_tracker_update)
			assert_nil icf_master_tracker_update.csv_file_file_name
			create_icf_master_tracker_update_test_file
			assert_difference('IcfMasterTrackerUpdate.count',0) {
				put :update, :id => icf_master_tracker_update.id, :icf_master_tracker_update => {
					:csv_file => Rack::Test::UploadedFile.new(csv_test_file_name)
				}
			}
			icf_master_tracker_update.reload
			assert_not_nil icf_master_tracker_update.csv_file_file_name
			assert_equal   icf_master_tracker_update.csv_file_file_name, csv_test_file_name
			assert File.exists?(icf_master_tracker_update.csv_file.path)
			assert_not_nil icf_master_tracker_update.csv_file_content_type
			assert_not_nil icf_master_tracker_update.csv_file_file_size
			assert_not_nil icf_master_tracker_update.csv_file_updated_at
			cleanup_icf_master_tracker_update_and_test_file(assigns(:icf_master_tracker_update))
		end

#	should I allow destroying?

		test "should destroy with csv_file attachment and #{cu} login" do
			login_as send(cu)
			icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
			assert_difference('IcfMasterTrackerUpdate.count',-1) {
				delete :destroy, :id => icf_master_tracker_update.id
			}
			cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
		end

		test "should parse with #{cu} login" do
			login_as send(cu)
			create_case_for_icf_master_tracker_update
			icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
			assert_difference('IcfMasterTracker.count',1){
				post :parse, :id => icf_master_tracker_update.id
			}
			assert assigns(:csv_lines)
			assert assigns(:results)
			assert_template 'parse'
			cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
		end

		test "should parse with #{cu} login and nil csv_file" do
			login_as send(cu)
			icf_master_tracker_update = Factory(:icf_master_tracker_update)
			assert_difference('IcfMasterTracker.count',0){
				post :parse, :id => icf_master_tracker_update.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to assigns(:icf_master_tracker_update)
			cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
		end

		test "should parse with #{cu} login and missing csv_file" do
			login_as send(cu)
			icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
			File.delete(icf_master_tracker_update.csv_file.path)
			assert_difference('IcfMasterTracker.count',0){
				post :parse, :id => icf_master_tracker_update.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to assigns(:icf_master_tracker_update)
			cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
		end

		test "should parse with #{cu} login and real csv_file" do
			real_data_file = 'icf_master_tracker_011712.csv'
			#	real data and won't be in repository
			unless File.exists?(real_data_file)
				puts
				puts "-- Real data test file does not exist. Skipping."
				return 
			end
			login_as send(cu)

			#	minimal semi-real case creation
			s1 = Factory(:study_subject,:sex => 'F',
				:first_name => 'FakeFirst1',:last_name => 'FakeLast1', 
				:dob => Date.parse('10/16/1977'))

			s2 = Factory(:study_subject,:sex => 'F',
				:first_name => 'FakeFirst2',:last_name => 'FakeLast2', 
				:dob => Date.parse('9/21/1988'))
			Factory(:icf_master_id,:icf_master_id => '15270110G')
			s2.assign_icf_master_id

			s3 = Factory(:study_subject,:sex => 'M',
				:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
				:dob => Date.parse('6/1/2009'))
			Factory(:icf_master_id,:icf_master_id => '15397125B')
			s3.assign_icf_master_id

			icf_master_tracker_update = Factory(:icf_master_tracker_update,
				:csv_file => File.open(real_data_file) )
			assert_not_nil icf_master_tracker_update.csv_file_file_name

			assert_difference('IcfMasterTracker.count',62){
				post :parse, :id => icf_master_tracker_update.id
			}
			assert_equal assigns(:results).length, 62
			assigns(:results).each { |r|
				assert  r.is_a?(IcfMasterTracker)
				assert !r.new_record?
			}

			assert assigns(:csv_lines)
			assert assigns(:results)
			icf_master_tracker_update.destroy
		end

	end

	non_site_administrators.each do |cu|

		test "should not parse with #{cu} login" do
			login_as send(cu)
			create_case_for_icf_master_tracker_update
			icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
			assert_difference('IcfMasterTracker.count',0){
				post :parse, :id => icf_master_tracker_update.id
			}
			cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
		end

	end

	test "should not parse without login" do
		create_case_for_icf_master_tracker_update
		icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
		assert_difference('IcfMasterTracker.count',0){
			post :parse, :id => icf_master_tracker_update.id
		}
		cleanup_icf_master_tracker_update_and_test_file(icf_master_tracker_update)
	end

end
