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
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.medical_record_requests.create
			get :new
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_medical_record_requests)
			assert_not_nil assigns(:waitlist_medical_record_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
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

		test "should add case study_subject to medical_record_requests with existing complete" <<
				" medical_record_request and #{cu} login patid" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			case_study_subject.medical_record_requests.create(:status => 'complete')
			assert_difference('MedicalRecordRequest.count',1) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).medical_record_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_medical_record_request_path
		end

		test "should add case study_subject to medical_record_requests with existing complete" <<
				" medical_record_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			case_study_subject.medical_record_requests.create(:status => 'complete')
			assert_difference('MedicalRecordRequest.count',1) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).medical_record_requests.last.status
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
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			MedicalRecordRequest.any_instance.stubs(:valid?).returns(false)
			deny_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
				put :update_status, :id => mdr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update medical_record_request status with failed save and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			MedicalRecordRequest.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
				put :update_status, :id => mdr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update medical_record_request status with invalid status and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			deny_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
				put :update_status, :id => mdr.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update medical_record_request status with invalid id and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			deny_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_medical_record_request_path
		end

		test "should update medical_record_request status with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			assert_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
				put :update_status, :id => mdr.id, :status => 'waitlist'
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
			mdr = case_study_subject.medical_record_requests.create
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 1, assigns(:medical_record_requests).length
		end

		test "should export medical_record_requests to csv with #{cu} login and requests" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject,
				:mother_maiden_name => '',
				:mother_last_name   => 'momlastname'
			)
			mdr = case_study_subject.medical_record_requests.create
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
#			assert_equal f[0], ["masterid", "biomom", "biodad", "date", "mother_full_name", "mother_maiden_name", "father_full_name", "child_full_name", "child_dobm", "child_dobd", "child_doby", "child_gender", "birthplace_country", "birthplace_state", "birthplace_city", "mother_hispanicity", "mother_hispanicity_mex", "mother_race", "other_mother_race", "father_hispanicity", "father_hispanicity_mex", "father_race", "other_father_race"]
			assert_equal f[0], %w( masterid biomom biodad date mother_full_name mother_maiden_name father_full_name 
				child_first_name child_middle_name child_last_name child_dobm child_dobd child_doby child_gender 
				birthplace_country birthplace_state birthplace_city mother_hispanicity mother_hispanicity_mex 
				mother_race other_mother_race father_hispanicity father_hispanicity_mex father_race other_father_race )
			assert_equal 25, f[0].length
#["46", nil, nil, nil, "[name not available]", nil, "[name not available]", "[name not available]", "3", "23", "2006", "F", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
			assert_equal f[1][0],  case_study_subject.icf_master_id
			#	mother_maiden_name column, but mother_maiden_name is blank
			assert_equal f[1][5],  case_study_subject.mother_last_name
			assert_equal f[1][10],  case_study_subject.dob.try(:month).to_s
			assert_equal f[1][11],  case_study_subject.dob.try(:day).to_s
			assert_equal f[1][12], case_study_subject.dob.try(:year).to_s
			assert_equal f[1][13], case_study_subject.sex

#assert f[2].blank?
		end

		test "should get pending medical_record_requests with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mdr = case_study_subject.medical_record_requests.create(:status => 'pending')
			get :index, :status => 'pending'
			assert_response :success
			assert_template 'index'
			assert assigns(:medical_record_requests)
			assert !assigns(:medical_record_requests).empty?
			assert_equal 1, assigns(:medical_record_requests).length
			assert_equal 'pending', assigns(:medical_record_requests).first.status
		end

		test "should confirm actives exported with #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_equal 1, case_study_subject.enrollments.length
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			get :confirm
			assert_redirected_to new_medical_record_request_path
			assert_equal 'pending', mdr.reload.status
			assert_equal Date.current, mdr.sent_on
			assert !case_study_subject.reload.enrollments.empty?
			enrollment = case_study_subject.enrollments.first
			assert_equal Project['ccls'], enrollment.project

			assert !case_study_subject.operational_events.empty?
			assert_equal 2, case_study_subject.operational_events.length
			assert_equal OperationalEventType['medical_record_request_sent'],
				case_study_subject.operational_events.last.operational_event_type
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event creation fails" do
			login_as send(cu)
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_equal 1, case_study_subject.enrollments.length
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
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
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			assert_equal 1, case_study_subject.enrollments.length
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
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
			FactoryGirl.create(:medical_record_request, :status => 'active')
			FactoryGirl.create(:medical_record_request, :status => 'active')
			FactoryGirl.create(:medical_record_request, :status => 'active')
			assert_equal 0, MedicalRecordRequest.waitlist.length
			assert_equal 3, MedicalRecordRequest.active.length
			put :waitlist_all_active
			assert_equal 3, MedicalRecordRequest.waitlist.length
			assert_equal 0, MedicalRecordRequest.active.length
			assert_not_nil flash[:notice]
			assert_redirected_to new_medical_record_request_path
		end

		test "should activate all waiting with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:medical_record_request, :status => 'waitlist')
			FactoryGirl.create(:medical_record_request, :status => 'waitlist')
			FactoryGirl.create(:medical_record_request, :status => 'waitlist')
			assert_equal 3, MedicalRecordRequest.waitlist.length
			assert_equal 0, MedicalRecordRequest.active.length
			put :activate_all_waitlist
			assert_equal 0, MedicalRecordRequest.waitlist.length
			assert_equal 3, MedicalRecordRequest.active.length
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
			case_study_subject = FactoryGirl.create(:complete_case_study_subject)
			mdr = case_study_subject.medical_record_requests.create(:status => 'active')
			deny_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
				put :update_status, :id => mdr.id, :status => 'waitlist'
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
			FactoryGirl.create(:medical_record_request, :status => 'waitlist')
			FactoryGirl.create(:medical_record_request, :status => 'waitlist')
			FactoryGirl.create(:medical_record_request, :status => 'waitlist')
			assert_equal 3, MedicalRecordRequest.waitlist.length
			assert_equal 0, MedicalRecordRequest.active.length
			put :activate_all_waitlist
			assert_equal 3, MedicalRecordRequest.waitlist.length
			assert_equal 0, MedicalRecordRequest.active.length
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT waitlist all active with #{cu} login" do
			login_as send(cu)
			FactoryGirl.create(:medical_record_request, :status => 'active')
			FactoryGirl.create(:medical_record_request, :status => 'active')
			FactoryGirl.create(:medical_record_request, :status => 'active')
			assert_equal 0, MedicalRecordRequest.waitlist.length
			assert_equal 3, MedicalRecordRequest.active.length
			put :waitlist_all_active
			assert_equal 0, MedicalRecordRequest.waitlist.length
			assert_equal 3, MedicalRecordRequest.active.length
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
		case_study_subject = FactoryGirl.create(:complete_case_study_subject)
		mdr = case_study_subject.medical_record_requests.create(:status => 'active')
		deny_changes("MedicalRecordRequest.find(#{mdr.id}).status") {
			put :update_status, :id => mdr.id, :status => 'waitlist'
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
		FactoryGirl.create(:medical_record_request, :status => 'waitlist')
		FactoryGirl.create(:medical_record_request, :status => 'waitlist')
		FactoryGirl.create(:medical_record_request, :status => 'waitlist')
		assert_equal 3, MedicalRecordRequest.waitlist.length
		assert_equal 0, MedicalRecordRequest.active.length
		put :activate_all_waitlist
		assert_equal 3, MedicalRecordRequest.waitlist.length
		assert_equal 0, MedicalRecordRequest.active.length
		assert_redirected_to_login
	end

	test "should NOT waitlist all active without login" do
		FactoryGirl.create(:medical_record_request, :status => 'active')
		FactoryGirl.create(:medical_record_request, :status => 'active')
		FactoryGirl.create(:medical_record_request, :status => 'active')
		assert_equal 0, MedicalRecordRequest.waitlist.length
		assert_equal 3, MedicalRecordRequest.active.length
		put :waitlist_all_active
		assert_equal 0, MedicalRecordRequest.waitlist.length
		assert_equal 3, MedicalRecordRequest.active.length
		assert_redirected_to_login
	end

end
