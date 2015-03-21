require 'test_helper'

class MedicalRecordRequestsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model => 'MedicalRecordRequest',
		:actions => [:new,:edit,:update,:destroy],		
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_medical_record_request
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:medical_record_request)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

	site_editors.each do |cu|

		test "should get new with existing medical_record_requests and #{cu} login" do
			login_as send(cu)
			create_case_subjects_with_active_request(1)
			get :new
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_medical_record_requests)
			assert_not_nil assigns(:waitlist_medical_record_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new and order existing by studyid with #{cu} login" do
			login_as send(cu)
			mr1,mr2,mr3 = create_case_subjects_with_active_request(3)
			get :new, :order => :studyid
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_medical_record_requests)
			assert_not_nil assigns(:waitlist_medical_record_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [mr1,mr2,mr3], assigns(:active_medical_record_requests)
		end

		test "should get new and order existing by studyid asc with #{cu} login" do
			login_as send(cu)
			mr1,mr2,mr3 = create_case_subjects_with_active_request(3)
			get :new, :order => :studyid, :dir => :asc
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_medical_record_requests)
			assert_not_nil assigns(:waitlist_medical_record_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [mr1,mr2,mr3], assigns(:active_medical_record_requests)
		end

		test "should get new and order existing by studyid desc with #{cu} login" do
			login_as send(cu)
			mr1,mr2,mr3 = create_case_subjects_with_active_request(3)
			get :new, :order => :studyid, :dir => :desc
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_medical_record_requests)
			assert_not_nil assigns(:waitlist_medical_record_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [mr1,mr2,mr3], assigns(:active_medical_record_requests).reverse
		end

		test "should NOT add case study_subject to medical_record_requests without q" <<
				" and #{cu} login" do
			login_as send(cu)
			assert_difference('MedicalRecordRequest.count',0) {
				post :create
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path
		end

		test "should NOT add case study_subject to medical_record_requests without matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => 'NOPE'
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path( :q => 'NOPE' )
		end

		test "should NOT add case study_subject to medical_record_requests without matching" <<
				" icf master id and #{cu} login" do
			login_as send(cu)
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => 'donotmatch'
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path(:q => 'donotmatch')
		end

		#	non-case is effectively not a valid patid
		test "should NOT add case study_subject to medical_record_requests with non-case" <<
				" study_subject patid and #{cu} login" do
			login_as send(cu)
			non_case_study_subject = FactoryGirl.create(:study_subject, :patid => '1234')
			assert non_case_study_subject.persisted?
			assert_not_nil non_case_study_subject.patid
			assert_equal non_case_study_subject.patid, '1234'
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => non_case_study_subject.patid
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path(:q => non_case_study_subject.patid)
		end

		test "should NOT add case study_subject to medical_record_requests with non-case" <<
				" study_subject icf master id and #{cu} login" do
			login_as send(cu)
			non_case_study_subject = FactoryGirl.create(:study_subject, :icf_master_id => '12345')
			assert non_case_study_subject.persisted?
			assert_not_nil non_case_study_subject.icf_master_id
			assert_equal non_case_study_subject.icf_master_id, '12345'
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => non_case_study_subject.icf_master_id
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path(:q => non_case_study_subject.icf_master_id)
		end

		test "should NOT add case study_subject to medical_record_requests with existing incomplete" <<
				" medical_record_request and #{cu} login patid" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.medical_record_requests.create
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should NOT add case study_subject to medical_record_requests with existing incomplete" <<
				" medical_record_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_not_nil case_study_subject.icf_master_id
			case_study_subject.medical_record_requests.create
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should NOT add case study_subject to medical_record_requests with existing complete" <<
				" medical_record_request and #{cu} login patid" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.medical_record_requests.create(:status => 'completed')
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should NOT add case study_subject to medical_record_requests with existing complete" <<
				" medical_record_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			case_study_subject.medical_record_requests.create(:status => 'completed')
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should add case study_subject to medical_record_requests with matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_difference('MedicalRecordRequest.count',1) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).medical_record_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should add case study_subject to medical_record_requests with matching icf master id" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_difference('MedicalRecordRequest.count',1) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).medical_record_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should add case study_subject to medical_record_requests with matching patid" <<
				" missing leading zeroes and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			# case_study_subject.patid should be a small 4-digit string
			#		with leading zeroes. (probably 0001). Remove them before submit.
			patid = case_study_subject.patid.to_i
			assert patid < 1000, 
				'Expected auto-generated patid to be less than 1000 for this test'
			assert_difference('MedicalRecordRequest.count',1) {
				post :create, :q => patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).medical_record_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should NOT update medical_record_request status with invalid medical_record_request #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.medical_record_requests.create(:status => 'active')
			MedicalRecordRequest.any_instance.stubs(:valid?).returns(false)
			deny_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update medical_record_request status with failed save and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.medical_record_requests.create(:status => 'active')
			MedicalRecordRequest.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update medical_record_request status with invalid status and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.medical_record_requests.create(:status => 'active')
			deny_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update medical_record_request status with invalid id and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.medical_record_requests.create(:status => 'active')
			deny_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path
		end

		test "should update medical_record_request status with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.medical_record_requests.create(:status => 'active')
			assert_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'waitlist'
			}
			assert_not_nil assigns(:medical_record_request)
			assert_nil flash[:error]
			assert_redirected_to new_medical_record_request_path
		end

		test "should get medical_record_requests with #{cu} login" do
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert assigns(:medical_record_requests).empty?
			assert_equal 0, assigns(:medical_record_requests).length
		end

		test "should get medical_record_requests with #{cu} login and requests" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mrr = case_study_subject.medical_record_requests.create
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 1, assigns(:medical_record_requests).length
		end

		MedicalRecordRequest.statuses.each do |status|

			test "should get #{status} medical_record_requests with #{cu} login" do
				login_as send(cu)
				case_study_subject = FactoryGirl.create(:complete_case_study_subject)
				mrr = case_study_subject.medical_record_requests.create(:status => status )
				get :index, :status => status
				assert_response :success
				assert_template 'index'
				assert assigns(:medical_record_requests)
				assert !assigns(:medical_record_requests).empty?
				assert_equal 1, assigns(:medical_record_requests).length
				assert_equal status, assigns(:medical_record_requests).first.status
			end

		end

		test "should export medical_record_requests to csv with #{cu} login and requests" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:mother_maiden_name => '',
				:mother_last_name   => 'momlastname'
			)
			mrr = case_study_subject.medical_record_requests.create
			get :index, :format => 'csv'
			assert_response :success
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 1, assigns(:medical_record_requests).length
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

		test "should get medical_record_requests and order existing by studyid with #{cu} login" do
			login_as send(cu)
			mr1,mr2,mr3 = create_case_subjects_with_active_request(3)
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 3, assigns(:medical_record_requests).length
			assert_equal [mr1,mr2,mr3], assigns(:medical_record_requests)
		end

		test "should get medical_record_requests and order existing by studyid asc with #{cu} login" do
			login_as send(cu)
			mr1,mr2,mr3 = create_case_subjects_with_active_request(3)
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 3, assigns(:medical_record_requests).length
			assert_equal [mr1,mr2,mr3], assigns(:medical_record_requests)
		end

		test "should get medical_record_requests and order existing by studyid desc with #{cu} login" do
			login_as send(cu)
			mr1,mr2,mr3 = create_case_subjects_with_active_request(3)
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 3, assigns(:medical_record_requests).length
			assert_equal [mr1,mr2,mr3], assigns(:medical_record_requests)
		end

		test "should confirm actives exported with #{cu} login" do
			login_as send(cu)
			mrr = create_case_subjects_with_active_request(1).first
			assert_equal 1, mrr.study_subject.enrollments.length
			get :confirm
			assert_redirected_to new_medical_record_request_path
			assert_equal 'pending', mrr.reload.status
			assert_equal Date.current, mrr.sent_on
			assert !mrr.study_subject.reload.enrollments.empty?
			enrollment = mrr.study_subject.enrollments.first
			assert_equal Project['ccls'], enrollment.project

			assert !mrr.study_subject.operational_events.empty?
			assert_equal 2, mrr.study_subject.operational_events.length
			assert_equal OperationalEventType['medical_record_request_sent'],
				mrr.study_subject.operational_events.last.operational_event_type
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event creation fails" do
			login_as send(cu)
			mrr = create_case_subjects_with_active_request(1).first
			assert_equal 1, mrr.study_subject.enrollments.length
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event invalid" do
			login_as send(cu)
			mrr = create_case_subjects_with_active_request(1).first
			assert_equal 1, mrr.study_subject.enrollments.length
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path
		end

		test "should waitlist all active with #{cu} login" do
			login_as send(cu)
			create_medical_record_requests(3,:status => 'active')
			assert_equal 0, MedicalRecordRequest.waitlist.count
			assert_equal 3, MedicalRecordRequest.active.count
			put :waitlist_all_active
			assert_equal 3, MedicalRecordRequest.waitlist.count
			assert_equal 0, MedicalRecordRequest.active.count
			assert_not_nil flash[:notice]
			assert_redirected_to new_medical_record_request_path
		end

		test "should activate all waiting with #{cu} login" do
			login_as send(cu)
			create_medical_record_requests(3,:status => 'waitlist')
			assert_equal 3, MedicalRecordRequest.waitlist.count
			assert_equal 0, MedicalRecordRequest.active.count
			put :activate_all_waitlist
			assert_equal 0, MedicalRecordRequest.waitlist.count
			assert_equal 3, MedicalRecordRequest.active.count
			assert_not_nil flash[:notice]
			assert_redirected_to new_medical_record_request_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT add case study_subject to medical_record_requests with matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT add case study_subject to medical_record_requests with matching icf master id" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_difference('MedicalRecordRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update medical_record_request status with #{cu} login" do
			login_as send(cu)
			mrr = create_case_subjects_with_active_request(1).first
			deny_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
				put :update_status, :id => mrr.id, :status => 'waitlist'
			}
			assert_nil assigns(:medical_record_request)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get medical_record_requests with #{cu} login" do
			login_as send(cu)
			get :index
			assert_nil assigns(:medical_record_requests)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT confirm actives exported with #{cu} login" do
			login_as send(cu)
			get :confirm
			assert_nil assigns(:medical_record_requests)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT activate all waiting with #{cu} login" do
			login_as send(cu)
			create_medical_record_requests(3,:status => 'waitlist')
			assert_equal 3, MedicalRecordRequest.waitlist.count
			assert_equal 0, MedicalRecordRequest.active.count
			put :activate_all_waitlist
			assert_equal 3, MedicalRecordRequest.waitlist.count
			assert_equal 0, MedicalRecordRequest.active.count
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT waitlist all active with #{cu} login" do
			login_as send(cu)
			create_medical_record_requests(3,:status => 'active')
			assert_equal 0, MedicalRecordRequest.waitlist.count
			assert_equal 3, MedicalRecordRequest.active.count
			put :waitlist_all_active
			assert_equal 0, MedicalRecordRequest.waitlist.count
			assert_equal 3, MedicalRecordRequest.active.count
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...
#

	test "should NOT add case study_subject to medical_record_requests with matching patid" <<
			" and without login" do
		case_study_subject = FactoryGirl.create(:complete_case_study_subject)
		assert_difference('MedicalRecordRequest.count',0) {
			post :create, :q => case_study_subject.patid
		}
		assert_nil assigns(:study_subject)
		assert_redirected_to_login
	end

	test "should NOT add case study_subject to medical_record_requests with matching icf master id" <<
			" and without login" do
		case_study_subject = FactoryGirl.create(:complete_case_study_subject,
			:icf_master_id => '12345')
		assert_difference('MedicalRecordRequest.count',0) {
			post :create, :q => case_study_subject.icf_master_id
		}
		assert_nil assigns(:study_subject)
		assert_redirected_to_login
	end

	test "should NOT update medical_record_request status without login" do
		mrr = create_case_subjects_with_active_request(1).first
		deny_changes("MedicalRecordRequest.find(#{mrr.id}).status") {
			put :update_status, :id => mrr.id, :status => 'waitlist'
		}
		assert_redirected_to_login
	end

	test "should NOT get medical_record_requests without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT confirm actives exported without login" do
		get :confirm
		assert_redirected_to_login
	end

	test "should NOT activate all waiting without login" do
		create_medical_record_requests(3,:status => 'waitlist')
		assert_equal 3, MedicalRecordRequest.waitlist.count
		assert_equal 0, MedicalRecordRequest.active.count
		put :activate_all_waitlist
		assert_equal 3, MedicalRecordRequest.waitlist.count
		assert_equal 0, MedicalRecordRequest.active.count
		assert_redirected_to_login
	end

	test "should NOT waitlist all active without login" do
		create_medical_record_requests(3,:status => 'active')
		assert_equal 0, MedicalRecordRequest.waitlist.count
		assert_equal 3, MedicalRecordRequest.active.count
		put :waitlist_all_active
		assert_equal 0, MedicalRecordRequest.waitlist.count
		assert_equal 3, MedicalRecordRequest.active.count
		assert_redirected_to_login
	end

	test "medical_record_request_params should require medical_record_request" do
		@controller.params=HWIA.new(:no_medical_record_request => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:medical_record_request_params).permitted?
		}
	end

	[ :status,:sent_on,:returned_on,:is_found,:notes ].each do |attr|
		test "medical_record_request_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:medical_record_request => { attr => 'funky' })
			assert @controller.send(:medical_record_request_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "medical_record_request_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:medical_record_request => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:medical_record_request_params).permitted?
				assert  @controller.params[:medical_record_request].has_key?(attr)
				assert !@controller.send(:medical_record_request_params).has_key?(attr)
			}
		end
	end

	def create_medical_record_requests(count=1,options={})
		count.times.collect { FactoryGirl.create(:medical_record_request, options) }
	end

	def create_case_subjects_with_active_request(count=1)
		count.times.collect {
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mr = case_study_subject.medical_record_requests.create(:status => 'active')
		}
	end

end
