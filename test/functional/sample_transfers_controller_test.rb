require 'test_helper'

class SampleTransfersControllerTest < ActionController::TestCase

	site_administrators.each do |cu|

		test "should destroy with #{cu} login" do
			sample_transfer = FactoryGirl.create(:sample_transfer)
			login_as send(cu)
			assert_difference('SampleTransfer.count',-1){
				delete :destroy, :id => sample_transfer.id
			}
			assert_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT destroy with invalid id #{cu} login" do
			sample_transfer = FactoryGirl.create(:sample_transfer)
			login_as send(cu)
			assert_difference('SampleTransfer.count',0){
				delete :destroy, :id => 0
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT destroy with #{cu} login" do
			sample_transfer = FactoryGirl.create(:sample_transfer)
			login_as send(cu)
			assert_difference('SampleTransfer.count',0){
				delete :destroy, :id => sample_transfer.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_editors.each do |cu|

		test "should not confirm without organization_id with #{cu} login" do
			login_as send(cu)
			put :confirm
			assert_redirected_to sample_transfers_path
			assert_not_nil flash[:error]
			assert_match /Valid organization id required/, flash[:error]
		end

		test "should not confirm without valid organization_id with #{cu} login" do
			login_as send(cu)
			put :confirm, :organization_id => 0
			assert_redirected_to sample_transfers_path
			assert_not_nil flash[:error]
			assert_match /Valid organization id required/, flash[:error]
		end

		test "confirm should do what with sample transfer update_all fail and #{cu} login" do
			prep_confirm_test
			login_as send(cu)
#			SampleTransfer.any_instance.stubs(:create_or_update).returns(false)

			#
			#	update_all will never raise this error, or any really.  Nevertheless
			#
			ActiveRecord::Relation.any_instance.stubs(:update_all).raises(ActiveRecord::RecordNotSaved)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
#	how to fake a fail update_all and does it raise an error?
#flunk 'manually flunked'
			assert_not_nil flash[:error]
#TODO not particularly descriptive "Something really bad happened"
			assert_match /Something really bad happened/, flash[:error]
		end

		test "confirm should fail with operational event invalid and #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('OperationalEvent.count',0){
				put :confirm, :organization_id => Organization['GEGL'].id
			}
			assert_redirected_to sample_transfers_path
			assert_not_nil flash[:error]
#TODO not particularly descriptive "Something really bad happened"
			assert_match /Something really bad happened/, flash[:error]
		end

		test "confirm should fail with operational event create fail and #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('OperationalEvent.count',0){
				put :confirm, :organization_id => Organization['GEGL'].id
			}
			assert_redirected_to sample_transfers_path
			assert_not_nil flash[:error]
#TODO not particularly descriptive "Something really bad happened"
			assert_match /Something really bad happened/, flash[:error]
		end

#	can't create a typeless sample so invalid test
#		test "confirm should do what with typeless sample and #{cu} login" do
#			prep_confirm_test
#			login_as send(cu)
#			put :confirm, :organization_id => Organization['GEGL'].id
#			assert_redirected_to sample_transfers_path
#		end

#	can't create a projectless sample so invalid test
#		test "confirm should do what with projectless sample and #{cu} login" do
#			prep_confirm_test
#			login_as send(cu)
#			put :confirm, :organization_id => Organization['GEGL'].id
#			assert_redirected_to sample_transfers_path
#		end

		test "confirm should work with locationless sample and #{cu} login" do
			prep_confirm_test(:active_sample => { :location_id => nil })
			SampleTransfer.active.each { |st| assert_nil st.sample.location_id }
			login_as send(cu)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
		end

		test "confirm should do what with subjectless sample and #{cu} login" do
			prep_confirm_test(:active_sample => { :study_subject => nil })
			login_as send(cu)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
		end

		test "confirm should require active transfers with #{cu} login" do
			#	prep_confirm_test	#	<- don't do this
			login_as send(cu)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			assert_not_nil flash[:error]
			assert_match /Active sample transfers required to confirm/, flash[:error]
		end

		test "confirm should set each sample location_id with #{cu} login" do
			prep_confirm_test
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			assert_equal 3.times.collect{Organization['CCLS'].id},
				active_transfers.collect(&:reload).collect(&:sample).collect(&:location_id)
			login_as send(cu)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			assert_equal 3.times.collect{Organization['GEGL'].id},
				active_transfers.collect(&:reload).collect(&:sample).collect(&:location_id)
		end

		test "confirm should set each sample sent_to_lab_at with #{cu} login" do
			prep_confirm_test
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			login_as send(cu)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			#	as this is a datetime, can't test EXACT, so just test date portion
			assert_equal 3.times.collect{Date.current},
				active_transfers.collect(&:reload).collect(&:sample)
					.collect(&:sent_to_lab_at).collect(&:to_date)
		end

		test "confirm should set each sample transfer destination_org_id with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			assert_equal 3.times.collect{nil},
				active_transfers.collect(&:destination_org_id)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			assert_equal 3.times.collect{Organization['GEGL'].id},
				active_transfers.collect(&:reload).collect(&:destination_org_id)
		end

		test "confirm should set each sample transfer sent_on with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			assert_equal 3.times.collect{nil},
				active_transfers.collect(&:sent_on)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			assert_equal 3.times.collect{Date.current},
				active_transfers.collect(&:reload).collect(&:sent_on)
		end

		test "confirm should set each sample transfer status with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			assert_equal 3.times.collect{'active'},
				active_transfers.collect(&:status)
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			assert_equal 3.times.collect{'complete'},
				active_transfers.collect(&:reload).collect(&:status)
		end

		test "confirm should create operational event for each sample with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			assert_difference('OperationalEvent.count',3){
				put :confirm, :organization_id => Organization['GEGL'].id
			}
			assert_redirected_to sample_transfers_path
		end

		test "confirm should set each operational event type with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
#			assert_difference("OperationalEvent.where(:operational_event_type_id => OperationalEventType['sample_to_lab'].id ).count",3){
			assert_difference("OperationalEventType['sample_to_lab'].operational_events.count",3){
				put :confirm, :organization_id => Organization['GEGL'].id
			}
			assert_redirected_to sample_transfers_path
		end

		test "confirm should set each operational event project with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			active_transfers.collect(&:reload).collect(&:sample).each do |s|
				assert s.study_subject.operational_events.collect(&:project).include?(s.project)
			end
		end

		test "confirm should set each operational event description with #{cu} login" do
			prep_confirm_test
			login_as send(cu)
			active_transfers = SampleTransfer.active.all	#	must do before as status changes
			put :confirm, :organization_id => Organization['GEGL'].id
			assert_redirected_to sample_transfers_path
			OperationalEventType['sample_to_lab'].operational_events.each {|oe| 
				assert_match /Sample ID \d{7}, \w+, transferred to GEGL from \w+/, 
					oe.description }
		end

		test "should NOT update sample_transfer status with invalid sample_transfer #{cu} login" do
			login_as send(cu)
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
			SampleTransfer.any_instance.stubs(:valid?).returns(false)
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT update sample_transfer status with failed save and #{cu} login" do
			login_as send(cu)
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
			SampleTransfer.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT update sample_transfer status with invalid status and #{cu} login" do
			login_as send(cu)
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should NOT update sample_transfer status with invalid id and #{cu} login" do
			login_as send(cu)
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

		test "should update sample_transfer status with #{cu} login" do
			login_as send(cu)
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
			assert_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_not_nil assigns(:sample_transfer)
			assert_nil flash[:error]
			assert_redirected_to sample_transfers_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT update sample_transfer status with #{cu} login" do
			login_as send(cu)
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
			deny_changes("SampleTransfer.find(#{st.id}).status") {
				put :update_status, :id => st.id, :status => 'waitlist'
			}
			assert_nil assigns(:sample_transfer)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

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
			st = FactoryGirl.create(:sample_transfer, :status => 'waitlist')
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
			st = FactoryGirl.create(:sample_transfer, :status => 'active')
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
			st = FactoryGirl.create(:sample_transfer, :status => 'active' )
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

	end

	non_site_readers.each do |cu|

		test "should NOT get sample transfers index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get sample transfers index without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT update sample_transfer status without login" do
		st = FactoryGirl.create(:sample_transfer, :status => 'active')
		deny_changes("SampleTransfer.find(#{st.id}).status") {
			put :update_status, :id => st.id, :status => 'waitlist'
		}
		assert_redirected_to_login
	end

protected

	def prep_confirm_test(options={})
		assert_difference('SampleTransfer.waitlist.count',3) {
		assert_difference('SampleTransfer.active.count',3) {
		assert_difference('SampleTransfer.count',6) {
		assert_difference('Sample.count',6) {
		3.times { 
			study_subject = FactoryGirl.create(:study_subject)
			active_sample = FactoryGirl.create(:sample, { :study_subject => study_subject
				}.merge(options[:active_sample]||{}))
			waitlist_sample = FactoryGirl.create(:sample, { :study_subject => study_subject
				}.merge(options[:waitlist_sample]||{}))
			FactoryGirl.create(:active_sample_transfer,   { :sample => active_sample
				}.merge(options[:active_sample_transfer]||{}))
			FactoryGirl.create(:waitlist_sample_transfer, { :sample => waitlist_sample
				}.merge(options[:waitlist_sample_transfer]||{}))
		} } } } }
	end

end
