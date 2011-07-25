require 'test_helper'

class BcRequestsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model => 'BcRequest',
		:actions => [:new,:destroy],
		:method_for_create => :create_bc_request
	}

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login
	assert_access_with_https
	assert_no_access_with_http

	site_editors.each do |cu|

		test "should get new with existing bc_requests and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			case_subject.create_bc_request
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

		test "should NOT add case subject to bc_requests with existing bc_request and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			case_subject.create_bc_request
			assert_difference('BcRequest.count',0) {
				post :create, :patid => case_subject.patid
			}
			assert_not_nil assigns(:subject)
			assert_not_nil flash[:error]
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
			assert_equal 'active', assigns(:subject).bc_request.status
			assert_equal case_subject, assigns(:subject)
			assert_redirected_to new_bc_request_path
		end

		test "should NOT update bc_requests with invalid id and #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.create_bc_request(:status => 'active')
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should update bc_requests with #{cu} login" do
			login_as send(cu)
			case_subject = create_case_control_subject
			bcr = case_subject.create_bc_request(:status => 'active')
			assert_changes("BcRequest.find(#{bcr.id}).status") {
				put :update, :id => bcr.id, :status => 'waitlist'
			}
			assert_not_nil assigns(:bc_request)
			assert_nil flash[:error]
			assert_redirected_to new_bc_request_path
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

protected

	def create_case_control_subject
		create_case_subject(
			'identifier_attributes' => { 'case_control_type' => 'C' })
	end

end
