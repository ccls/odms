require 'test_helper'

class BcRequestsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model => 'BcRequest',
		:actions => [:new,:edit,:update,:destroy],		#,:index], index is a bit tricky so done manually
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_bc_request
	}

	def factory_attributes(options={})
		Factory.attributes_for(:bc_request)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_editors.each do |cu|

		test "should get new with existing bc_requests and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			case_subject.bc_requests.create
			get :new
			assert_nil assigns(:subject)
			assert_not_nil assigns(:active_bc_requests)
			assert_not_nil assigns(:waitlist_bc_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT add case subject to bc_requests without patid and #{cu} login" do
			login_as send(cu)
			assert_difference('BcRequest.count',0) {
				post :create
			}
			assert_nil assigns(:subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT add case subject to bc_requests without matching patid and #{cu} login" do
			login_as send(cu)
			assert_difference('BcRequest.count',0) {
				post :create, :patid => 'donotmatchpatid'
			}
			assert_nil assigns(:subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		#	create multiple subjects and stub search so all returned mimicing multiple matches
		test "should NOT add case subject to bc_requests with multiple matching patid and #{cu} login" do
			login_as send(cu)
			create_case_control_subject
			create_case_control_subject
			Subject.any_instance.stubs(:search).returns(Subject.all)
			assert_difference('BcRequest.count',0) {
				post :create, :patid => 'irrelevant_for_this_test'
			}
			assert_nil assigns(:subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		#	non-case is effectively not a valid patid
		test "should NOT add case subject to bc_requests with non-case subject and #{cu} login" do
			login_as send(cu)
			non_case_subject = create_subject_with_patid('1234')
			assert !non_case_subject.new_record?
			assert_not_nil non_case_subject.patid
			assert_difference('BcRequest.count',0) {
				post :create, :patid => non_case_subject.patid
			}
			assert_nil assigns(:subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT add case subject to bc_requests with existing incomplete bc_request and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			case_subject.bc_requests.create
			assert_difference('BcRequest.count',0) {
				post :create, :patid => case_subject.patid
			}
			assert_not_nil assigns(:subject)
			assert_not_nil flash[:error]
			assert_equal case_subject, assigns(:subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case subject to bc_requests with existing complete bc_request and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			case_subject.bc_requests.create(:status => 'complete')
			assert_difference('BcRequest.count',1) {
				post :create, :patid => case_subject.patid
			}
			assert_not_nil assigns(:subject)
			assert_equal 'active', assigns(:subject).bc_requests.last.status
			assert_equal case_subject, assigns(:subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case subject to bc_requests with matching patid and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert_difference('BcRequest.count',1) {
				post :create, :patid => case_subject.patid
			}
			assert_not_nil assigns(:subject)
			assert_equal 'active', assigns(:subject).bc_requests.last.status
			assert_equal case_subject, assigns(:subject)
			assert_redirected_to new_bc_request_path
		end

		test "should NOT update bc_request status with invalid status and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create(:status => 'active')
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => bcr.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT update bc_request status with invalid id and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create(:status => 'active')
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should update bc_request status with #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create(:status => 'active')
			assert_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => bcr.id, :status => 'waitlist'
			}
			assert_not_nil assigns(:bc_request)
			assert_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should get bc_requests with #{cu} login" do
			login_as send(cu)
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert assigns(:bc_requests).empty?
			assert_equal 0, assigns(:bc_requests).length
		end

		test "should get bc_requests with #{cu} login and requests" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 1, assigns(:bc_requests).length
		end

		test "should export bc_requests to csv with #{cu} login and requests" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create
			get :index, :format => 'csv'
			assert_response :success
			assert_not_nil @response.headers['Content-disposition'].match(/attachment;.*csv/)
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 1, assigns(:bc_requests).length
		end

		test "should get pending bc_requests with #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create(:status => 'pending')
			get :index, :status => 'pending'
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 1, assigns(:bc_requests).length
			assert_equal 'pending', assigns(:bc_requests).first.status
		end

		test "should confirm actives exported with #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert case_subject.enrollments.empty?
			bcr = case_subject.bc_requests.create(:status => 'active')
			get :confirm
			assert_redirected_to new_bc_request_path
			assert_equal 'pending', bcr.reload.status
			assert_equal Date.today, bcr.sent_on
			assert !case_subject.reload.enrollments.empty?
			enrollment = case_subject.enrollments.first
			assert_equal Project['phase5'], enrollment.project
			assert !enrollment.operational_events.empty?
			assert_equal 1, enrollment.operational_events.length
			assert_equal OperationalEventType['bc_request_sent'],
				enrollment.operational_events.first.operational_event_type
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"enrollment creation fails" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert case_subject.enrollments.empty?
			bcr = case_subject.bc_requests.create(:status => 'active')
			Enrollment.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"enrollment invalid" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert case_subject.enrollments.empty?
			bcr = case_subject.bc_requests.create(:status => 'active')
			Enrollment.any_instance.stubs(:valid?).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event creation fails" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert case_subject.enrollments.empty?
			bcr = case_subject.bc_requests.create(:status => 'active')
			OperationalEvent.any_instance.stubs(:create_or_update).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event invalid" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert case_subject.enrollments.empty?
			bcr = case_subject.bc_requests.create(:status => 'active')
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT update bc_request with #{cu} login and bc_request invalid" do
pending
		end

		test "should NOT update bc_request with #{cu} login and save fails" do
pending
		end

	end

	non_site_editors.each do |cu|

		test "should NOT add case subject to bc_requests with matching patid and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			assert_difference('BcRequest.count',0) {
				post :create, :patid => case_subject.patid
			}
			assert_nil assigns(:subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update bc_request status with #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.bc_requests.create(:status => 'active')
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => bcr.id, :status => 'waitlist'
			}
			assert_nil assigns(:bc_request)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT get bc_requests with #{cu} login" do
			login_as send(cu)
			get :index
			assert_nil assigns(:bc_requests)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT confirm actives exported with #{cu} login" do
			login_as send(cu)
			get :confirm
			assert_nil assigns(:bc_requests)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...
#

	test "should NOT add case subject to bc_requests with matching patid and without login" do
		case_subject = create_case_control_subject
		assert_difference('BcRequest.count',0) {
			post :create, :patid => case_subject.patid
		}
		assert_nil assigns(:subject)
		assert_redirected_to_login
	end

	test "should NOT update bc_request status without login" do
		case_subject = create_case_control_subject
		bcr = case_subject.bc_requests.create(:status => 'active')
		deny_changes("BcRequest.find(#{bcr.id}).status") {
			put :update_status, :id => bcr.id, :status => 'waitlist'
		}
		assert_redirected_to_login
	end

	test "should NOT get bc_requests without login" do
		get :index
		assert_redirected_to_login
	end

	test "should NOT confirm actives exported without login" do
		get :confirm
		assert_redirected_to_login
	end

end
