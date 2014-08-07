require 'test_helper'

class BloodSpotRequestsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model => 'BloodSpotRequest',
		:actions => [:new,:edit,:update,:destroy],		
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_blood_spot_request
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:blood_spot_request)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

	site_editors.each do |cu|

		test "should get new with existing blood_spot_requests and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.blood_spot_requests.create
			get :new
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_blood_spot_requests)
			assert_not_nil assigns(:waitlist_blood_spot_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new and order existing by studyid with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr1 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr2 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr3 = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :new, :order => :studyid
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_blood_spot_requests)
			assert_not_nil assigns(:waitlist_blood_spot_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [mr1,mr2,mr3], assigns(:active_blood_spot_requests)
		end

		test "should get new and order existing by studyid asc with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr1 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr2 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr3 = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :new, :order => :studyid, :dir => :asc
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_blood_spot_requests)
			assert_not_nil assigns(:waitlist_blood_spot_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [mr1,mr2,mr3], assigns(:active_blood_spot_requests)
		end

		test "should get new and order existing by studyid desc with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr1 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr2 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr3 = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :new, :order => :studyid, :dir => :desc
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_blood_spot_requests)
			assert_not_nil assigns(:waitlist_blood_spot_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [mr1,mr2,mr3], assigns(:active_blood_spot_requests).reverse
		end

		test "should NOT add case study_subject to blood_spot_requests without q" <<
				" and #{cu} login" do
			login_as send(cu)
			assert_difference('BloodSpotRequest.count',0) {
				post :create
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path
		end

		test "should NOT add case study_subject to blood_spot_requests without matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => 'NOPE'
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path( :q => 'NOPE' )
		end

		test "should NOT add case study_subject to blood_spot_requests without matching" <<
				" icf master id and #{cu} login" do
			login_as send(cu)
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => 'donotmatch'
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path(:q => 'donotmatch')
		end

		#	non-case is effectively not a valid patid
		test "should NOT add case study_subject to blood_spot_requests with non-case" <<
				" study_subject patid and #{cu} login" do
			login_as send(cu)
			non_case_study_subject = FactoryGirl.create(:study_subject, :patid => '1234')
			assert non_case_study_subject.persisted?
			assert_not_nil non_case_study_subject.patid
			assert_equal non_case_study_subject.patid, '1234'
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => non_case_study_subject.patid
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path(:q => non_case_study_subject.patid)
		end

		test "should NOT add case study_subject to blood_spot_requests with non-case" <<
				" study_subject icf master id and #{cu} login" do
			login_as send(cu)
			non_case_study_subject = FactoryGirl.create(:study_subject, :icf_master_id => '12345')
			assert non_case_study_subject.persisted?
			assert_not_nil non_case_study_subject.icf_master_id
			assert_equal non_case_study_subject.icf_master_id, '12345'
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => non_case_study_subject.icf_master_id
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path(:q => non_case_study_subject.icf_master_id)
		end

		test "should NOT add case study_subject to blood_spot_requests with existing incomplete" <<
				" blood_spot_request and #{cu} login patid" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.blood_spot_requests.create
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should NOT add case study_subject to blood_spot_requests with existing incomplete" <<
				" blood_spot_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_not_nil case_study_subject.icf_master_id
			case_study_subject.blood_spot_requests.create
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should NOT add case study_subject to blood_spot_requests with existing complete" <<
				" blood_spot_request and #{cu} login patid" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.blood_spot_requests.create(:status => 'complete')
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should NOT add case study_subject to blood_spot_requests with existing complete" <<
				" blood_spot_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			case_study_subject.blood_spot_requests.create(:status => 'complete')
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should add case study_subject to blood_spot_requests with matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_difference('BloodSpotRequest.count',1) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).blood_spot_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should add case study_subject to blood_spot_requests with matching icf master id" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_difference('BloodSpotRequest.count',1) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).blood_spot_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should add case study_subject to blood_spot_requests with matching patid" <<
				" missing leading zeroes and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			# case_study_subject.patid should be a small 4-digit string
			#		with leading zeroes. (probably 0001). Remove them before submit.
			patid = case_study_subject.patid.to_i
			assert patid < 1000, 
				'Expected auto-generated patid to be less than 1000 for this test'
			assert_difference('BloodSpotRequest.count',1) {
				post :create, :q => patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).blood_spot_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_blood_spot_request_path
		end

		test "should NOT update blood_spot_request status with invalid blood_spot_request #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			BloodSpotRequest.any_instance.stubs(:valid?).returns(false)
			deny_changes("BloodSpotRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update blood_spot_request status with failed save and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			BloodSpotRequest.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("BloodSpotRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update blood_spot_request status with invalid status and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			deny_changes("BloodSpotRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update blood_spot_request status with invalid id and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			deny_changes("BloodSpotRequest.find(#{mrr.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path
		end

		test "should update blood_spot_request status with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			assert_changes("BloodSpotRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'waitlist'
			}
			assert_not_nil assigns(:blood_spot_request)
			assert_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path
		end

		test "should get blood_spot_requests with #{cu} login" do
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert assigns(:blood_spot_requests).empty?
			assert_equal 0, assigns(:blood_spot_requests).length
		end

		test "should get blood_spot_requests with #{cu} login and requests" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
		end

		test "should get pending blood_spot_requests with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'pending')
			get :index, :status => 'pending'
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
			assert_equal 'pending', assigns(:blood_spot_requests).first.status
		end

		test "should get active blood_spot_requests with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :index, :status => 'active'
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
			assert_equal 'active', assigns(:blood_spot_requests).first.status
		end

		test "should get waitlist blood_spot_requests with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'waitlist')
			get :index, :status => 'waitlist'
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
			assert_equal 'waitlist', assigns(:blood_spot_requests).first.status
		end

		test "should get abstracted blood_spot_requests with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'abstracted')
			get :index, :status => 'abstracted'
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
			assert_equal 'abstracted', assigns(:blood_spot_requests).first.status
		end

		test "should get complete blood_spot_requests with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'complete')
			get :index, :status => 'complete'
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
			assert_equal 'complete', assigns(:blood_spot_requests).first.status
		end

		test "should export blood_spot_requests to csv with #{cu} login and requests" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:mother_maiden_name => '',
				:mother_last_name   => 'momlastname'
			)
			mrr = case_study_subject.blood_spot_requests.create
			get :index, :format => 'csv'
			assert_response :success
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 1, assigns(:blood_spot_requests).length
			assert_nil     case_study_subject.mother_maiden_name
			assert_not_nil case_study_subject.mother_last_name

			require 'csv'
			f = CSV.parse(@response.body)
			assert_equal 2, f.length	#	2 rows, 1 header and 1 data
			assert_equal f[0], %w(patid icf_master_id hospital_no first_name last_name dob ccls_is_eligible 
				ccls_is_consented admit_date hospital )
			assert_equal 10, f[0].length
			#	"["0001", nil, "67", nil, nil, "02/16/1991", nil, nil, "04/02/2014", "Packard Children's Hospital - Stanford"]"
			assert_equal f[1][0],  case_study_subject.patid
			assert_equal f[1][1],  case_study_subject.icf_master_id
			assert_equal f[1][2],  case_study_subject.hospital_no
			assert_equal f[1][3],  case_study_subject.first_name
			assert_equal f[1][4],  case_study_subject.last_name
			assert_equal f[1][5],  case_study_subject.dob.try(:strftime,'%m/%d/%Y')
			assert_equal f[1][6],  case_study_subject.ccls_is_eligible
			assert_equal f[1][7],  case_study_subject.ccls_is_consented
			assert_equal f[1][8],  case_study_subject.admit_date.try(:strftime,'%m/%d/%Y')
			assert_equal f[1][9],  case_study_subject.hospital
		end

		test "should get blood_spot_requests and order existing by studyid with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr1 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr2 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr3 = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 3, assigns(:blood_spot_requests).length
			assert_equal [mr1,mr2,mr3], assigns(:blood_spot_requests)
		end

		test "should get blood_spot_requests and order existing by studyid asc with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr1 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr2 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr3 = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 3, assigns(:blood_spot_requests).length
			assert_equal [mr1,mr2,mr3], assigns(:blood_spot_requests)
		end

		test "should get blood_spot_requests and order existing by studyid desc with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr1 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr2 = case_study_subject.blood_spot_requests.create(:status => 'active')
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr3 = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:blood_spot_requests)
			assert !assigns(:blood_spot_requests).empty?
			assert_equal 3, assigns(:blood_spot_requests).length
			assert_equal [mr1,mr2,mr3], assigns(:blood_spot_requests)
		end

		test "should confirm actives exported with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_equal 1, case_study_subject.enrollments.length
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			get :confirm
			assert_redirected_to new_blood_spot_request_path
			assert_equal 'pending', mrr.reload.status
			assert_equal Date.current, mrr.sent_on
			assert !case_study_subject.reload.enrollments.empty?
			enrollment = case_study_subject.enrollments.first
			assert_equal Project['ccls'], enrollment.project

			assert !case_study_subject.operational_events.empty?
			assert_equal 2, case_study_subject.operational_events.length
			assert_equal OperationalEventType['blood_spot_request_sent'],
				case_study_subject.operational_events.last.operational_event_type
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event creation fails" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_equal 1, case_study_subject.enrollments.length
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event invalid" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_equal 1, case_study_subject.enrollments.length
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_blood_spot_request_path
		end

		test "should waitlist all active with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:blood_spot_request, :status => 'active')
			FactoryGirl.create(:blood_spot_request, :status => 'active')
			FactoryGirl.create(:blood_spot_request, :status => 'active')
			assert_equal 0, BloodSpotRequest.waitlist.length
			assert_equal 3, BloodSpotRequest.active.length
			put :waitlist_all_active
			assert_equal 3, BloodSpotRequest.waitlist.length
			assert_equal 0, BloodSpotRequest.active.length
			assert_not_nil flash[:notice]
			assert_redirected_to new_blood_spot_request_path
		end

		test "should activate all waiting with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
			FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
			FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
			assert_equal 3, BloodSpotRequest.waitlist.length
			assert_equal 0, BloodSpotRequest.active.length
			put :activate_all_waitlist
			assert_equal 0, BloodSpotRequest.waitlist.length
			assert_equal 3, BloodSpotRequest.active.length
			assert_not_nil flash[:notice]
			assert_redirected_to new_blood_spot_request_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT add case study_subject to blood_spot_requests with matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT add case study_subject to blood_spot_requests with matching icf master id" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_difference('BloodSpotRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update blood_spot_request status with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
			deny_changes("BloodSpotRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'waitlist'
			}
			assert_nil assigns(:blood_spot_request)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get blood_spot_requests with #{cu} login" do
			login_as send(cu)
			get :index
			assert_nil assigns(:blood_spot_requests)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT confirm actives exported with #{cu} login" do
			login_as send(cu)
			get :confirm
			assert_nil assigns(:blood_spot_requests)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT activate all waiting with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
			FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
			FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
			assert_equal 3, BloodSpotRequest.waitlist.length
			assert_equal 0, BloodSpotRequest.active.length
			put :activate_all_waitlist
			assert_equal 3, BloodSpotRequest.waitlist.length
			assert_equal 0, BloodSpotRequest.active.length
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT waitlist all active with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:blood_spot_request, :status => 'active')
			FactoryGirl.create(:blood_spot_request, :status => 'active')
			FactoryGirl.create(:blood_spot_request, :status => 'active')
			assert_equal 0, BloodSpotRequest.waitlist.length
			assert_equal 3, BloodSpotRequest.active.length
			put :waitlist_all_active
			assert_equal 0, BloodSpotRequest.waitlist.length
			assert_equal 3, BloodSpotRequest.active.length
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...
#

	test "should NOT add case study_subject to blood_spot_requests with matching patid" <<
			" and without login" do
		case_study_subject = FactoryGirl.create(:complete_case_study_subject)
		assert_difference('BloodSpotRequest.count',0) {
			post :create, :q => case_study_subject.patid
		}
		assert_nil assigns(:study_subject)
		assert_redirected_to_login
	end

	test "should NOT add case study_subject to blood_spot_requests with matching icf master id" <<
			" and without login" do
		case_study_subject = FactoryGirl.create(:complete_case_study_subject,
			:icf_master_id => '12345')
		assert_difference('BloodSpotRequest.count',0) {
			post :create, :q => case_study_subject.icf_master_id
		}
		assert_nil assigns(:study_subject)
		assert_redirected_to_login
	end

	test "should NOT update blood_spot_request status without login" do
		case_study_subject = FactoryGirl.create(:complete_case_study_subject)
		mrr = case_study_subject.blood_spot_requests.create(:status => 'active')
		deny_changes("BloodSpotRequest.find(#{mrr.id}).status") {
			put :update_status, :id => mrr.id, :status => 'waitlist'
		}
		assert_redirected_to_login
	end

	test "should NOT get blood_spot_requests without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT confirm actives exported without login" do
		get :confirm
		assert_redirected_to_login
	end

	test "should NOT activate all waiting without login" do
		FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
		FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
		FactoryGirl.create(:blood_spot_request, :status => 'waitlist')
		assert_equal 3, BloodSpotRequest.waitlist.length
		assert_equal 0, BloodSpotRequest.active.length
		put :activate_all_waitlist
		assert_equal 3, BloodSpotRequest.waitlist.length
		assert_equal 0, BloodSpotRequest.active.length
		assert_redirected_to_login
	end

	test "should NOT waitlist all active without login" do
		FactoryGirl.create(:blood_spot_request, :status => 'active')
		FactoryGirl.create(:blood_spot_request, :status => 'active')
		FactoryGirl.create(:blood_spot_request, :status => 'active')
		assert_equal 0, BloodSpotRequest.waitlist.length
		assert_equal 3, BloodSpotRequest.active.length
		put :waitlist_all_active
		assert_equal 0, BloodSpotRequest.waitlist.length
		assert_equal 3, BloodSpotRequest.active.length
		assert_redirected_to_login
	end

end
