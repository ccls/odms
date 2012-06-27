require 'test_helper'

class SampleTransfersControllerTest < ActionController::TestCase

	site_administrators.each do |cu|

#sample.location_id is set to the source_org_id for each sample
#
#sample_transfers.destination_org_id is org selected in target location combo box
#
#the sample_transfer.sent_on date is set to the current date for each sample
#
#sample.ccls_external_id is set to "subjectid"+"-"+"sampleid" ensuring that all leading zeros are maintained (redundant but consistent with current practice -- to be revisited later)
#.
#The system creates a "Sample sent to lab" operational event (op event type id=6 "sample_to_lab") for each sample in the list. 
#
#operational_event.description = "Sample ID 0000000, peripheral blood, diagnostic, transferred to organization.key from organization.key"  
#
#Where the two organization keys are specified by target_org_id and source_org_id, respectively.
#
#sample_transfer.status = complete


		test "should confirm with #{cu} login" do
#skip
#puts "DO I KEEP RUNNING AFTER A SKIP?"	#	NO.  I DO NOT.
			login_as send(cu)
			put :confirm
			assert_redirected_to sample_transfers_path
#puts "DO I RUN STUFF BEFORE A SKIP?"	#	YES.  I DO.
skip
		end


		test "should get sample transfers index with #{cu} login and no transfers" do
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:active_sample_transfers)
			assert assigns(:active_sample_transfers).empty?
			assert assigns(:waitlist_sample_transfers)
			assert assigns(:waitlist_sample_transfers).empty?
		end

		test "should get sample transfers index with #{cu} login and waitlist transfers" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'waitlist')
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:active_sample_transfers)
			assert assigns(:active_sample_transfers).empty?
			assert assigns(:waitlist_sample_transfers)
			assert !assigns(:waitlist_sample_transfers).empty?
			assert_equal 1, assigns(:waitlist_sample_transfers).length
		end

		test "should get sample transfers index with #{cu} login and active transfers" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:active_sample_transfers)
			assert !assigns(:active_sample_transfers).empty?
			assert_equal 1, assigns(:active_sample_transfers).length
			assert assigns(:waitlist_sample_transfers)
			assert assigns(:waitlist_sample_transfers).empty?
		end

		test "should export sample transfers to csv with #{cu} login and active transfers" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active' )
			get :index, :format => 'csv'
			assert_response :success
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert_template 'index'
			assert assigns(:active_sample_transfers)
			assert !assigns(:active_sample_transfers).empty?
			assert_equal 1, assigns(:active_sample_transfers).length
			assert assigns(:waitlist_sample_transfers)
			assert assigns(:waitlist_sample_transfers).empty?

			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	2 rows, 1 header and 1 data
#			assert_equal f[0], ["masterid", "biomom", "biodad", "date", "mother_full_name", "mother_maiden_name", "father_full_name", "child_full_name", "child_dobm", "child_dobd", "child_doby", "child_gender", "birthplace_country", "birthplace_state", "birthplace_city", "mother_hispanicity", "mother_hispanicity_mex", "mother_race", "other_mother_race", "father_hispanicity", "father_hispanicity_mex", "father_race", "other_father_race"]
#			assert_equal 23, f[0].length
##["46", nil, nil, nil, "[name not available]", nil, "[name not available]", "[name not available]", "3", "23", "2006", "F", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
#			assert_equal f[1][0],  case_study_subject.icf_master_id
#			assert_equal f[1][8],  case_study_subject.dob.try(:month).to_s
#			assert_equal f[1][9],  case_study_subject.dob.try(:day).to_s
#			assert_equal f[1][10], case_study_subject.dob.try(:year).to_s
#			assert_equal f[1][11], case_study_subject.sex
		end

		test "should NOT update sample_transfer status with invalid sample_transfer #{cu} login" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			SampleTransfer.any_instance.stubs(:valid?).returns(false)
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT update sample_transfer status with failed save and #{cu} login" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			SampleTransfer.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT update sample_transfer status with invalid status and #{cu} login" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT update sample_transfer status with invalid id and #{cu} login" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should update sample_transfer status with #{cu} login" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			assert_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_not_nil assigns(:sample_transfer)
			assert_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT get sample transfers index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update sample_transfer status with #{cu} login" do
			login_as send(cu)
			st = Factory(:sample_transfer, :status => 'active')
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_nil assigns(:sample_transfer)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get sample transfers index without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT update sample_transfer status without login" do
		st = Factory(:sample_transfer, :status => 'active')
		deny_changes("SampleTransfer.find(#{st.id}).status") {
			put :update_status, :id => st.id, :status => 'waitlist'
		}
		assert_redirected_to_login
	end

end
