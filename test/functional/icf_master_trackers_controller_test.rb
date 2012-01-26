require 'test_helper'

class IcfMasterTrackersControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IcfMasterTracker',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_icf_master_tracker
	}
	#	IcfMasterTracker have no attributes other than the csv_file
	#	so need to add the updated_at to force a difference
	#	on update.
	def factory_attributes(options={})
		Factory.attributes_for(:icf_master_tracker,{
			:updated_at => Time.now }.merge(options))
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_administrators.each do |cu|

		test "should create with csv_file attachment and #{cu} login" do
			login_as send(cu)
			File.open(test_file_name,'w'){|f|f.puts 'testing'}
			assert_difference('IcfMasterTracker.count',1) {
				post :create, :icf_master_tracker => {
					:csv_file => File.open(test_file_name)
				}
			}
			assert_not_nil assigns(:icf_master_tracker).csv_file_file_name
			assert_not_nil assigns(:icf_master_tracker).csv_file_file_name
			assert_equal   assigns(:icf_master_tracker).csv_file_file_name, test_file_name
			assert_not_nil assigns(:icf_master_tracker).csv_file_content_type
			assert_not_nil assigns(:icf_master_tracker).csv_file_file_size
			assert_not_nil assigns(:icf_master_tracker).csv_file_updated_at
			cleanup_icf_master_tracker_and_test_file(assigns(:icf_master_tracker))
		end

#	should I allow editting the file?

		test "should update with csv_file attachment and #{cu} login" do
			login_as send(cu)
			icf_master_tracker = Factory(:icf_master_tracker)
			assert_nil icf_master_tracker.csv_file_file_name
			File.open(test_file_name,'w'){|f|f.puts 'testing'}
			assert_difference('IcfMasterTracker.count',0) {
				put :update, :id => icf_master_tracker.id, :icf_master_tracker => {
					:csv_file => File.open(test_file_name)
				}
			}
			icf_master_tracker.reload
			assert File.exists?(icf_master_tracker.csv_file.path)
			assert_not_nil icf_master_tracker.csv_file_file_name
			assert_equal   icf_master_tracker.csv_file_file_name, test_file_name
			assert_not_nil icf_master_tracker.csv_file_content_type
			assert_not_nil icf_master_tracker.csv_file_file_size
			assert_not_nil icf_master_tracker.csv_file_updated_at
			cleanup_icf_master_tracker_and_test_file(assigns(:icf_master_tracker))
		end

#	should I allow destroying?

		test "should destroy with csv_file attachment and #{cu} login" do
			login_as send(cu)
			File.open(test_file_name,'w'){|f|f.puts 'testing'}
			icf_master_tracker = Factory(:icf_master_tracker,
				:csv_file => File.open(test_file_name) )
			assert File.exists?(icf_master_tracker.csv_file.path)
			assert_difference('IcfMasterTracker.count',-1) {
				delete :destroy, :id => icf_master_tracker.id
			}
			assert !File.exists?(icf_master_tracker.csv_file.path)
			#	explicit delete to remove test file
			File.delete(test_file_name)	
		end

#		test "should parse with #{cu} login" do
#			login_as send(cu)
#			create_case_for_icf_master_tracker
#			icf_master_tracker = create_test_file_and_icf_master_tracker
#			assert_difference('CandidateControl.count',1){
#				post :parse, :id => icf_master_tracker.id
#			}
#			cleanup_icf_master_tracker_and_test_file(icf_master_tracker)
#		end

	end

	non_site_administrators.each do |cu|

#		test "should not parse with #{cu} login" do
#			login_as send(cu)
#			create_case_for_icf_master_tracker
#			icf_master_tracker = create_test_file_and_icf_master_tracker
#			assert_difference('CandidateControl.count',0){
#				post :parse, :id => icf_master_tracker.id
#			}
#			cleanup_icf_master_tracker_and_test_file(icf_master_tracker)
#		end

	end

#	test "should not parse without login" do
#		create_case_for_icf_master_tracker
#		icf_master_tracker = create_test_file_and_icf_master_tracker
#		assert_difference('CandidateControl.count',0){
#			post :parse, :id => icf_master_tracker.id
#		}
#		cleanup_icf_master_tracker_and_test_file(icf_master_tracker)
#	end


protected

	def create_test_file_and_icf_master_tracker
		create_test_file
		icf_master_tracker = create_icf_master_tracker_with_file
	end

	def create_icf_master_tracker_with_file
		icf_master_tracker = Factory(:icf_master_tracker,
			:csv_file => File.open(test_file_name) )
		assert_not_nil icf_master_tracker.csv_file_file_name
		icf_master_tracker
	end

	def cleanup_icf_master_tracker_and_test_file(icf_master_tracker)
		#	explicit destroy to remove attachment
		icf_master_tracker.destroy	
#		assert !File.exists?(icf_master_tracker.csv_file.path)
		#	explicit delete to remove test file
		File.delete(test_file_name)	
		assert !File.exists?(test_file_name)
	end

#	def create_case_for_icf_master_tracker
#		icf_master_id = Factory(:icf_master_id,:icf_master_id => '1234FAKE')
#		study_subject = Factory(:complete_case_study_subject)
#		study_subject.assign_icf_master_id
#		assert_equal '1234FAKE', study_subject.icf_master_id
#		study_subject
#	end

	def csv_file_header
		%{"Masterid","Motherid","Record_Owner","Datereceived","Lastatt","Lastdisp","Currphone","Vacauthrecd","Recollect","Needpreincentive","Active_Phone","Recordsentformatching","Recordreceivedfrommatching","Sentpreincentive","Releasedtocati","Confirmedcaticontact","Refused","Deceasednotification","Eligible","Confirmationpacketsent","Catiprotocolexhausted","Newphonenumreleasedtocati","Pleanotificationsent","Casereturnedtoberkeleyfornewinf","Casereturnedfromberkeley","Caticomplete","Kitmothersent","Kitinfantsent","Kitchildsent","Kitadolescentsent","Kitmotherrefusedcode","Kitchildrefusedcode","Noresponsetoplea","Responsereceivedfromplea","Senttoinpersonfollowup","Kitmotherrecd","Kitchildrecvd","Thankyousent","Physrequestsent","Physresponsereceived"}
	end

	def create_test_file
		File.open(test_file_name,'w'){|f|
			f.puts csv_file_header
#			f.puts csv_file_case_study_subject
#			f.puts csv_file_control 
		}
	end

#	#	broke it down like this so that can access and compare the attributes
#	def control
#		{	:masterid => '1234FAKE',
#			:ca_co_status => 'control',
#			:biomom => 1,
#			:biodad => nil,
#			:date => nil,
#			:mother_full_name => 'Jill Johnson',
#			:mother_maiden_name => 'Jackson',
#			:father_full_name => 'Jack Johnson',
#			:child_full_name => 'Michael Johnson',
#			:child_dobm => 1,
#			:child_dobd => 6,
#			:child_doby => 2009,
#			:child_gender => 'M',
#			:birthplace_country => 'United States',
#			:birthplace_state => 'CA',
#			:birthplace_city => 'Oakland',
#			:mother_hispanicity => 2,
#			:mother_hispanicity_mex => 2,
#			:mother_race => 1,
#			:mother_race_other => nil,
#			:father_hispanicity => 2,
#			:father_hispanicity_mex => 2,
#			:father_race => 1,
#			:father_race_other => nil }
#	end

#	def turn_off_paperclip_logging
#		#	Is there I way to silence the paperclip output?  Yes...
#		Paperclip.options[:log] = false
#		#	Is there I way to capture the paperclip output for comparison?  Don't know.
#	end

	def test_file_name
		"icf_master_tracker_test_file.csv"
	end

end
