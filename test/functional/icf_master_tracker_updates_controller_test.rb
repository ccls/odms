require 'test_helper'

class IcfMasterTrackerUpdatesControllerTest < ActionController::TestCase
	include IcfMasterTrackerUpdateTestHelper

	#
	#	NOTE that paperclip attachments apparently don't get removed
	#		so we must do it on our own.  In addition, if the test
	#		fails before you do so, these files end up lying around.
	#		A bit of a pain in the butt.  So I added this explicit
	#		cleanup of the icf_master_tracker_update csv_files.
	#		Works very nicely.
	#
	
	#	setup :turn_off_paperclip_logging

	teardown :delete_all_possible_icf_master_tracker_update_attachments

	teardown :cleanup_icf_master_tracker_update_and_test_file	#	remove tmp/FILE.csv

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

	assert_access_with_login(    :logins => site_superusers )
	assert_no_access_with_login( :logins => non_site_superusers )
	assert_no_access_without_login

	site_superusers.each do |cu|

#		test "should get index with #{cu} login" do
#			login_as send(cu)
#			get :index
#			assert_response :success
#			assert_template 'index'
#		end
#
#		test "should get new with #{cu} login" do
#			login_as send(cu)
#			get :new
#			assert_response :success
#			assert_template 'new'
#		end

		test "should create with empty csv_file attachment and #{cu} login" do
			login_as send(cu)
			assert_difference('IcfMasterTrackerUpdate.count',1) {
				post :create, :icf_master_tracker_update => Factory.attributes_for(
					:empty_icf_master_tracker_update)
			}
			assigns(:icf_master_tracker_update).reload
			assert_not_nil flash[:notice]
			assert_nil     flash[:error]
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_file_name
#			assert_equal   assigns(:icf_master_tracker_update).csv_file_file_name, csv_test_file_name
			assert_equal   assigns(:icf_master_tracker_update).csv_file_file_name, 
				'empty_icf_master_tracker_update_test_file.csv'
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_content_type
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_file_size
			assert_not_nil assigns(:icf_master_tracker_update).csv_file_updated_at
			assigns(:icf_master_tracker_update).destroy
		end

#	should I allow editting the file?

#		test "should show with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			get :show, :id => icf_master_tracker_update.id
#			assert_response :success
#			assert_template 'show'
#		end
#
#		test "should edit with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			get :edit, :id => icf_master_tracker_update.id
#			assert_response :success
#			assert_template 'edit'
#		end

		test "should update with csv_file attachment and #{cu} login" do
			login_as send(cu)
			icf_master_tracker_update = Factory(:icf_master_tracker_update)
			assert_difference('IcfMasterTrackerUpdate.count',0) {
				put :update, :id => icf_master_tracker_update.id, 
					:icf_master_tracker_update => Factory.attributes_for(
						:icf_master_tracker_update)
			}
			icf_master_tracker_update.reload
			assert_not_nil icf_master_tracker_update.csv_file_file_name
#			assert_equal   icf_master_tracker_update.csv_file_file_name, csv_test_file_name
			assert File.exists?(icf_master_tracker_update.csv_file.path)
			assert_not_nil icf_master_tracker_update.csv_file_content_type
			assert_not_nil icf_master_tracker_update.csv_file_file_size
			assert_not_nil icf_master_tracker_update.csv_file_updated_at
			icf_master_tracker_update.destroy
		end

#	should I allow destroying?

#		test "should destroy with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			assert_difference('IcfMasterTrackerUpdate.count',-1) {
#				delete :destroy, :id => icf_master_tracker_update.id
#			}
#			#	shouldn't be needed, but ...
#			icf_master_tracker_update.destroy
#		end

#
#	need data here
#
		test "should parse empty csv file with #{cu} login" do
			login_as send(cu)
			icf_master_tracker_update = Factory(:empty_icf_master_tracker_update)
			assert_difference('IcfMasterTrackerChange.count',0){
			assert_difference('IcfMasterTracker.count',0){
				post :parse, :id => icf_master_tracker_update.id
			} }
			assert assigns(:csv_lines)
			assert assigns(:results)
			assert_template 'parse'
		end

		test "should parse one record csv file with #{cu} login" do
			login_as send(cu)
			icf_master_tracker_update = Factory(:one_record_icf_master_tracker_update)
			assert_difference('IcfMasterTrackerChange.count',17){
#	and now with the master_id changed (irrelevant so changed callback)
#			assert_difference('IcfMasterTrackerChange.count',18){
			assert_difference('IcfMasterTracker.count',1){
				post :parse, :id => icf_master_tracker_update.id
			} }
			assert assigns(:csv_lines)
			assert assigns(:results)
			assert_template 'parse'
		end

		test "should parse with #{cu} login and missing csv_file" do
			login_as send(cu)
			icf_master_tracker_update = Factory(:icf_master_tracker_update)
			File.delete(icf_master_tracker_update.csv_file.path)
			assert_difference('IcfMasterTrackerChange.count',0){
			assert_difference('IcfMasterTracker.count',0){
				post :parse, :id => icf_master_tracker_update.id
			} }
			assert_not_nil flash[:error]
			assert_redirected_to assigns(:icf_master_tracker_update)
		end

		test "should parse with #{cu} login and real csv_file" do
			#	real data and won't be in repository
			real_data_file = 'ICF_Master_Trackers/ICF_Master_Tracker_20120329.csv'
			unless File.exists?(real_data_file)
				puts
				puts "-- Real data test file does not exist. Skipping."
				return 
			end
			login_as send(cu)

#			#	minimal semi-real case creation
#			s1 = Factory(:study_subject,:sex => 'F',
#				:first_name => 'FakeFirst1',:last_name => 'FakeLast1', 
#				:dob => Date.parse('10/16/1977'))
#
#			s2 = Factory(:study_subject,:sex => 'F',
#				:first_name => 'FakeFirst2',:last_name => 'FakeLast2', 
#				:dob => Date.parse('9/21/1988'))
#			Factory(:icf_master_id,:icf_master_id => '15270110G')
#			s2.assign_icf_master_id
#
#			s3 = Factory(:study_subject,:sex => 'M',
#				:first_name => 'FakeFirst3',:last_name => 'FakeLast3', 
#				:dob => Date.parse('6/1/2009'))
#			Factory(:icf_master_id,:icf_master_id => '15397125B')
#			s3.assign_icf_master_id

			icf_master_tracker_update = Factory(:icf_master_tracker_update,
				:csv_file => File.open(real_data_file) )
			assert_not_nil icf_master_tracker_update.csv_file_file_name

			assert_difference('IcfMasterTrackerChange.count',1861){
#	and now with the master_id changed (irrelevant so changed callback)
#			assert_difference('IcfMasterTrackerChange.count',1958){
			assert_difference('IcfMasterTracker.count',95){
				post :parse, :id => icf_master_tracker_update.id
			} }
			assert_equal assigns(:results).length, 95
			assigns(:results).each { |r|
				assert  r.is_a?(IcfMasterTracker)
				assert !r.new_record?
			}

			assert assigns(:csv_lines)
			assert assigns(:results)
			icf_master_tracker_update.destroy
		end

	end

	non_site_superusers.each do |cu|

#		test "should not get index with #{cu} login" do
#			login_as send(cu)
#			get :index
#			assert_redirected_to root_path
#		end
#
#		test "should not get new with #{cu} login" do
#			login_as send(cu)
#			get :new
#			assert_redirected_to root_path
#		end
#
#		test "should not create with #{cu} login" do
#			login_as send(cu)
#			assert_difference('IcfMasterTrackerUpdate.count',0){
#				post :create, :icf_master_tracker_update => Factory.attributes_for(
#					:empty_icf_master_tracker_update)
#			}
#			assert_redirected_to root_path
#		end
#
#		test "should not edit with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			get :edit, :id => icf_master_tracker_update.id
#			assert_redirected_to root_path
#		end
#
#		test "should not update with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			put :update, :id => icf_master_tracker_update.id, 
#				:icf_master_tracker_update => Factory.attributes_for(
#					:icf_master_tracker_update)
#			assert_redirected_to root_path
#		end
#
#		test "should not show with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			get :show, :id => icf_master_tracker_update.id
#			assert_redirected_to root_path
#		end
#
#		test "should not destroy with #{cu} login" do
#			login_as send(cu)
#			icf_master_tracker_update = Factory(:icf_master_tracker_update)
#			assert_difference('IcfMasterTrackerUpdate.count',0){
#				delete :destroy, :id => icf_master_tracker_update.id
#			}
#			assert_redirected_to root_path
#		end

		test "should not parse with #{cu} login" do
			login_as send(cu)
			create_case_for_icf_master_tracker_update
			icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
			assert_difference('IcfMasterTracker.count',0){
				post :parse, :id => icf_master_tracker_update.id
			}
			assert_redirected_to root_path
		end

	end

#	test "should not get index without login" do
#		get :index
#		assert_redirected_to_login
#	end
#
#	test "should not get new without login" do
#		get :new
#		assert_redirected_to_login
#	end
#
#	test "should not create without login" do
#		assert_difference('IcfMasterTrackerUpdate.count',0){
#			post :create, :icf_master_tracker_update => Factory.attributes_for(
#				:empty_icf_master_tracker_update)
#		}
#		assert_redirected_to_login
#	end
#
#	test "should not edit without login" do
#		icf_master_tracker_update = Factory(:icf_master_tracker_update)
#		get :edit, :id => icf_master_tracker_update.id
#		assert_redirected_to_login
#	end
#
#	test "should not update without login" do
#		icf_master_tracker_update = Factory(:icf_master_tracker_update)
#		put :update, :id => icf_master_tracker_update.id, 
#			:icf_master_tracker_update => Factory.attributes_for(
#				:icf_master_tracker_update)
#		assert_redirected_to_login
#	end
#
#	test "should not show without login" do
#		icf_master_tracker_update = Factory(:icf_master_tracker_update)
#		get :show, :id => icf_master_tracker_update.id
#		assert_redirected_to_login
#	end
#
#	test "should not destroy without login" do
#		icf_master_tracker_update = Factory(:icf_master_tracker_update)
#		assert_difference('IcfMasterTrackerUpdate.count',0){
#			delete :destroy, :id => icf_master_tracker_update.id
#		}
#		assert_redirected_to_login
#	end

	test "should not parse without login" do
		create_case_for_icf_master_tracker_update
		icf_master_tracker_update = create_test_file_and_icf_master_tracker_update
		assert_difference('IcfMasterTracker.count',0){
			post :parse, :id => icf_master_tracker_update.id
		}
		assert_redirected_to_login
	end

protected

	def delete_all_possible_icf_master_tracker_update_attachments
		#	/bin/rm -rf test/icf_master_tracker_update
		FileUtils.rm_rf('test/icf_master_tracker_update')
	end

end
