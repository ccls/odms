require 'test_helper'

class BcRequestsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = { 
		:model => 'BcRequest',
		:actions => [:new,:edit,:update,:destroy],		
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_bc_request
	}

	def factory_attributes(options={})
		FactoryBot.attributes_for(:bc_request)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

	site_editors.each do |cu|

		test "should get new with existing bc_requests and #{cu} login" do
			login_as send(cu)
			create_case_subjects_with_active_bcr(1)
			get :new
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_bc_requests)
			assert_not_nil assigns(:waitlist_bc_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should get new and order existing by studyid with #{cu} login" do
			login_as send(cu)
			bc1,bc2,bc3 = create_case_subjects_with_active_bcr(3)
			get :new, :order => :studyid
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_bc_requests)
			assert_not_nil assigns(:waitlist_bc_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [bc1,bc2,bc3], assigns(:active_bc_requests)
		end

		test "should get new and order existing by studyid asc with #{cu} login" do
			login_as send(cu)
			bc1,bc2,bc3 = create_case_subjects_with_active_bcr(3)
			get :new, :order => :studyid, :dir => :asc
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_bc_requests)
			assert_not_nil assigns(:waitlist_bc_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [bc1,bc2,bc3], assigns(:active_bc_requests)
		end

		test "should get new and order existing by studyid desc with #{cu} login" do
			login_as send(cu)
			bc1,bc2,bc3 = create_case_subjects_with_active_bcr(3)
			get :new, :order => :studyid, :dir => :desc
			assert_nil assigns(:study_subject)
			assert_not_nil assigns(:active_bc_requests)
			assert_not_nil assigns(:waitlist_bc_requests)
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert_equal [bc1,bc2,bc3], assigns(:active_bc_requests).reverse
		end

		test "should NOT add case study_subject to bc_requests without q" <<
				" and #{cu} login" do
			login_as send(cu)
			assert_difference('BcRequest.count',0) {
				post :create
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should NOT add case study_subject to bc_requests without matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			assert_difference('BcRequest.count',0) {
				post :create, :q => 'NOPE'
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path( :q => 'NOPE' )
		end

		test "should NOT add case study_subject to bc_requests without matching" <<
				" icf master id and #{cu} login" do
			login_as send(cu)
			assert_difference('BcRequest.count',0) {
				post :create, :q => 'donotmatch'
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path(:q => 'donotmatch')
		end

		#	non-case is effectively not a valid patid
		test "should NOT add case study_subject to bc_requests with non-case" <<
				" study_subject patid and #{cu} login" do
			login_as send(cu)
			non_case_study_subject = FactoryBot.create(:study_subject, :patid => '1234')
			assert non_case_study_subject.persisted?
			assert_not_nil non_case_study_subject.patid
			assert_equal non_case_study_subject.patid, '1234'
			assert_difference('BcRequest.count',0) {
				post :create, :q => non_case_study_subject.patid
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path(:q => non_case_study_subject.patid)
		end

		test "should NOT add case study_subject to bc_requests with non-case" <<
				" study_subject icf master id and #{cu} login" do
			login_as send(cu)
			non_case_study_subject = FactoryBot.create(:study_subject, :icf_master_id => '12345')
			assert non_case_study_subject.persisted?
			assert_not_nil non_case_study_subject.icf_master_id
			assert_equal non_case_study_subject.icf_master_id, '12345'
			assert_difference('BcRequest.count',0) {
				post :create, :q => non_case_study_subject.icf_master_id
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path(:q => non_case_study_subject.icf_master_id)
		end

		test "should NOT add case study_subject to bc_requests with existing incomplete" <<
				" bc_request and #{cu} login patid" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			assert_difference('BcRequest.count',0) {
				post :create, :q => bcr.study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal bcr.study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should NOT add case study_subject to bc_requests with existing incomplete" <<
				" bc_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_not_nil case_study_subject.icf_master_id
			case_study_subject.bc_requests.create
			assert_difference('BcRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case study_subject to bc_requests with existing complete" <<
				" bc_request and #{cu} login patid" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject)
			case_study_subject.bc_requests.create(:status => 'completed')
			assert_difference('BcRequest.count',1) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).bc_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case study_subject to bc_requests with existing complete" <<
				" bc_request and #{cu} login icf master id" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			case_study_subject.bc_requests.create(:status => 'completed')
			assert_difference('BcRequest.count',1) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).bc_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case study_subject to bc_requests with matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject)
			assert_difference('BcRequest.count',1) {
				post :create, :q => case_study_subject.patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).bc_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case study_subject to bc_requests with matching icf master id" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_difference('BcRequest.count',1) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).bc_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should add case study_subject to bc_requests with matching patid" <<
				" missing leading zeroes and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject)
			# case_study_subject.patid should be a small 4-digit string
			#		with leading zeroes. (probably 0001). Remove them before submit.
			patid = case_study_subject.patid.to_i
			assert patid < 1000, 
				'Expected auto-generated patid to be less than 1000 for this test'
			assert_difference('BcRequest.count',1) {
				post :create, :q => patid
			}
			assert_not_nil assigns(:study_subject)
			assert_equal 'active', assigns(:study_subject).bc_requests.last.status
			assert_equal case_study_subject, assigns(:study_subject)
			assert_redirected_to new_bc_request_path
		end

		test "should NOT update bc_request status with invalid bc_request #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			BcRequest.any_instance.stubs(:valid?).returns(false)
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => bcr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update bc_request status with failed save and #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			BcRequest.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => bcr.id, :status => 'pending'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update bc_request status with invalid status and #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => bcr.id, :status => 'bogus'
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update bc_request status with invalid id and #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			deny_changes("BcRequest.find(#{bcr.id}).status") {
				put :update_status, :id => 0, :status => 'waitlist'
			}
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should update bc_request status with #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
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
			bcr = create_case_subjects_with_active_bcr(1).first
			get :index
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 1, assigns(:bc_requests).length
		end

		test "should export bc_requests to csv with #{cu} login and requests" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject,
				:mother_maiden_name => '',
				:mother_last_name   => 'momlastname'
			)
			bcr = case_study_subject.bc_requests.create
			get :index, :format => 'csv'
			assert_response :success
			assert_not_nil @response.headers['Content-Disposition'].match(/attachment;.*csv/)
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 1, assigns(:bc_requests).length
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

		BcRequest.statuses.each do |status|

			test "should get #{status} bc_requests with #{cu} login" do
				login_as send(cu)
				case_study_subject = FactoryBot.create(:complete_case_study_subject)
				bcr = case_study_subject.bc_requests.create(:status => status)
				get :index, :status => status
				assert_response :success
				assert_template 'index'
				assert assigns(:bc_requests)
				assert !assigns(:bc_requests).empty?
				assert_equal 1, assigns(:bc_requests).length
				assert_equal status, assigns(:bc_requests).first.status
			end

		end

		test "should get bc_requests and order existing by studyid with #{cu} login" do
			login_as send(cu)
			bc1,bc2,bc3 = create_case_subjects_with_active_bcr(3)
			get :index, :order => :studyid
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 3, assigns(:bc_requests).length
			assert_equal [bc1,bc2,bc3], assigns(:bc_requests)
		end

		test "should get bc_requests and order existing by studyid asc with #{cu} login" do
			login_as send(cu)
			bc1,bc2,bc3 = create_case_subjects_with_active_bcr(3)
			get :index, :order => :studyid, :dir => :asc
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 3, assigns(:bc_requests).length
			assert_equal [bc1,bc2,bc3], assigns(:bc_requests)
		end

		test "should get bc_requests and order existing by studyid desc with #{cu} login" do
			login_as send(cu)
			bc1,bc2,bc3 = create_case_subjects_with_active_bcr(3)
			get :index, :order => :studyid, :dir => :desc
			assert_response :success
			assert_template 'index'
			assert assigns(:bc_requests)
			assert !assigns(:bc_requests).empty?
			assert_equal 3, assigns(:bc_requests).length
			assert_equal [bc1,bc2,bc3], assigns(:bc_requests).reverse
		end

		test "should confirm actives exported with #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			assert_equal 1, bcr.study_subject.enrollments.length
			get :confirm
			assert_redirected_to new_bc_request_path
			assert_equal 'pending', bcr.reload.status
			assert_equal Date.current, bcr.sent_on
			assert !bcr.study_subject.reload.enrollments.empty?
			enrollment = bcr.study_subject.enrollments.first
			assert_equal Project['ccls'], enrollment.project

			assert !bcr.study_subject.operational_events.empty?
			assert_equal 2, bcr.study_subject.operational_events.length
			assert_equal OperationalEventType['bc_request_sent'],
				bcr.study_subject.operational_events.last.operational_event_type
		end

		test "should NOT confirm actives exported with #{cu} login if " <<
				"operational event creation fails" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
			assert_equal 1, bcr.study_subject.enrollments.length
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
			bcr = create_case_subjects_with_active_bcr(1).first
			assert_equal 1, bcr.study_subject.enrollments.length
			OperationalEvent.any_instance.stubs(:valid?).returns(false)
			assert_difference('Enrollment.count',0) {
			assert_difference('OperationalEvent.count',0) {
				get :confirm
			} }
			assert_not_nil flash[:error]
			assert_redirected_to new_bc_request_path
		end

		test "should waitlist all active with #{cu} login" do
			login_as send(cu)
			create_bc_requests(3, :status => 'active')
			assert_equal 0, BcRequest.waitlist.count
			assert_equal 3, BcRequest.active.count
			put :waitlist_all_active
			assert_equal 3, BcRequest.waitlist.count
			assert_equal 0, BcRequest.active.count
			assert_not_nil flash[:notice]
			assert_redirected_to new_bc_request_path
		end

		test "should activate all waiting with #{cu} login" do
			login_as send(cu)
			create_bc_requests(3, :status => 'waitlist')
			assert_equal 3, BcRequest.waitlist.count
			assert_equal 0, BcRequest.active.count
			put :activate_all_waitlist
			assert_equal 0, BcRequest.waitlist.count
			assert_equal 3, BcRequest.active.count
			assert_not_nil flash[:notice]
			assert_redirected_to new_bc_request_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT add case study_subject to bc_requests with matching patid" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject)
			assert_difference('BcRequest.count',0) {
				post :create, :q => case_study_subject.patid
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT add case study_subject to bc_requests with matching icf master id" <<
				" and #{cu} login" do
			login_as send(cu)
			case_study_subject = FactoryBot.create(:complete_case_study_subject,
				:icf_master_id => '12345')
			assert_difference('BcRequest.count',0) {
				post :create, :q => case_study_subject.icf_master_id
			}
			assert_nil assigns(:study_subject)
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update bc_request status with #{cu} login" do
			login_as send(cu)
			bcr = create_case_subjects_with_active_bcr(1).first
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

		test "should NOT activate all waiting with #{cu} login" do
			login_as send(cu)
			create_bc_requests(3, :status => 'waitlist')
			assert_equal 3, BcRequest.waitlist.count
			assert_equal 0, BcRequest.active.count
			put :activate_all_waitlist
			assert_equal 3, BcRequest.waitlist.count
			assert_equal 0, BcRequest.active.count
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT waitlist all active with #{cu} login" do
			login_as send(cu)
			create_bc_requests(3, :status => 'active')
			assert_equal 0, BcRequest.waitlist.count
			assert_equal 3, BcRequest.active.count
			put :waitlist_all_active
			assert_equal 0, BcRequest.waitlist.count
			assert_equal 3, BcRequest.active.count
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

#	no login ...
#

	test "should NOT add case study_subject to bc_requests with matching patid" <<
			" and without login" do
		case_study_subject = FactoryBot.create(:complete_case_study_subject)
		assert_difference('BcRequest.count',0) {
			post :create, :q => case_study_subject.patid
		}
		assert_nil assigns(:study_subject)
		assert_redirected_to_login
	end

	test "should NOT add case study_subject to bc_requests with matching icf master id" <<
			" and without login" do
		case_study_subject = FactoryBot.create(:complete_case_study_subject,
			:icf_master_id => '12345')
		assert_difference('BcRequest.count',0) {
			post :create, :q => case_study_subject.icf_master_id
		}
		assert_nil assigns(:study_subject)
		assert_redirected_to_login
	end

	test "should NOT update bc_request status without login" do
		bcr = create_case_subjects_with_active_bcr(1).first
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

	test "should NOT activate all waiting without login" do
		create_bc_requests(3, :status => 'waitlist')
		assert_equal 3, BcRequest.waitlist.count
		assert_equal 0, BcRequest.active.count
		put :activate_all_waitlist
		assert_equal 3, BcRequest.waitlist.count
		assert_equal 0, BcRequest.active.count
		assert_redirected_to_login
	end

	test "should NOT waitlist all active without login" do
		create_bc_requests(3, :status => 'active')
		assert_equal 0, BcRequest.waitlist.count
		assert_equal 3, BcRequest.active.count
		put :waitlist_all_active
		assert_equal 0, BcRequest.waitlist.count
		assert_equal 3, BcRequest.active.count
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :bc_request,
		[:status,:sent_on,:returned_on,:is_found,:notes ])

	def create_bc_requests(count=1,options={})
		count.times.collect { FactoryBot.create(:bc_request, options) }
	end

	def create_case_subjects_with_active_bcr(count=1)
		count.times.collect {
			case_study_subject = FactoryBot.create(:complete_case_study_subject)
			bcr = case_study_subject.bc_requests.create(:status => 'active')
		}
	end

end
