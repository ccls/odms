require 'test_helper'

class StudySubject::SamplesControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::SamplesController

#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Sample',
#		:actions => [:edit,:update,:destroy],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_sample
#	}
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_access_with_login({    :logins => site_readers, 
#		:actions => [:show] })
#	assert_no_access_with_login({ :logins => non_site_readers, 
#		:actions => [:show] })
#	assert_no_access_without_login

	#	no study_subject_id
	assert_no_route(:get,:index)

	#	no id
	assert_no_route(:get, :show)
	assert_no_route(:get, :edit)
	assert_no_route(:put, :update)
	assert_no_route(:delete, :destroy)

	def factory_attributes(options={})
		#	Being more explicit to reflect what is actually on the form
		{
			:project_id     => Project['ccls'].id,
			:sample_type_id => FactoryBot.create(:sample_type).id
		}.merge(options)
	end

	site_administrators.each do |cu|

		test "should destroy with #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			assert_difference('Sample.count',-1){
				delete :destroy, :study_subject_id => sample.study_subject_id, 
					:id => sample.id
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_path(sample.study_subject_id)
		end

		test "should NOT destroy with mismatched study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample)
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			assert_difference('Sample.count',0){
				delete :destroy, :study_subject_id => study_subject.id, 
					:id => sample.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			assert_difference('Sample.count',0){
				delete :destroy, :study_subject_id => 0,
					:id => sample.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid id #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			assert_difference('Sample.count',0){
				delete :destroy, :study_subject_id => sample.study_subject_id, 
					:id => 0
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT destroy with #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			assert_difference('Sample.count',0){
				delete :destroy, :study_subject_id => sample.study_subject_id, 
					:id => sample.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_editors.each do |cu|

		test "should get new sample with #{cu} login" <<
				" and study_subject_id" do
			login_as send(cu)
			study_subject = FactoryBot.create(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'new'
			assert assigns(:sample)
		end

		test "should NOT get new sample with #{cu} login" <<
				" and invalid study_subject_id" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new sample and transfer with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryBot.create(:study_subject)
			assert_difference('SampleTransfer.count',1) {
			assert_difference('Sample.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_nil flash[:error]
			assert_redirected_to study_subject_sample_path(study_subject,assigns(:sample))
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and invalid study_subject_id" do
			login_as send(cu)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => 0,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and invalid sample" do
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			study_subject = FactoryBot.create(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and sample save failure" do
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			study_subject = FactoryBot.create(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and invalid sample transfer" do
			login_as send(cu)
			SampleTransfer.any_instance.stubs(:valid?).returns(false)
			study_subject = FactoryBot.create(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should NOT create sample or transfer with #{cu} login " <<
				"and sample transfer save failure" do
			login_as send(cu)
			SampleTransfer.any_instance.stubs(:create_or_update).returns(false)
			study_subject = FactoryBot.create(:study_subject)
			assert_difference('SampleTransfer.count',0) {
			assert_difference('Sample.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:sample => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'new'
		end

		test "should edit with #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :edit, :study_subject_id => sample.study_subject_id, :id => sample.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit with mismatched study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample)
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id, :id => sample.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :edit, :study_subject_id => 0, :id => sample.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid id #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :edit, :study_subject_id => sample.study_subject_id, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update with #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => sample.study_subject_id, 
					:id => sample.id, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_sample_path(sample.study_subject_id,sample.id)
		end

		test "should NOT update with save failure and #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			Sample.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => sample.study_subject_id, 
					:id => sample.id, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with invalid and #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			Sample.any_instance.stubs(:valid?).returns(false)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => sample.study_subject_id, 
					:id => sample.id, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with mismatched study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id, 
					:id => sample.id, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:id => sample.id, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid id #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => sample.study_subject_id, 
					:id => 0, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end
	
	non_site_editors.each do |cu|

		test "should NOT get new sample with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryBot.create(:study_subject)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new sample with #{cu} login" do
			login_as send(cu)
			study_subject = FactoryBot.create(:study_subject)
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :edit, :study_subject_id => sample.study_subject_id, :id => sample.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Sample.find(#{sample.id}).updated_at") {
				put :update, :study_subject_id => sample.study_subject_id, 
					:id => sample.id, :sample => {
						:external_id_source => 'trigger update'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end
	
	site_readers.each do |cu|

		test "should get index with #{cu} login and valid study_subject_id" do
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_nil flash[:error]
			assert assigns(:samples)
			assert_response :success
			assert_template 'index'
		end

		test "should get index with #{cu} login and samples" do
			sample = FactoryBot.create(:sample).reload
			login_as send(cu)
			get :index, :study_subject_id => sample.study_subject_id
			assert_nil flash[:error]
			assert assigns(:samples)
			assert_response :success
			assert_template 'index'
		end

		test "should NOT get index with #{cu} login and invalid study_subject_id" do
			login_as send(cu)
			get :index, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end
	
		test "should show pdf with #{cu} login" do
			login_as send(cu)
			sample = FactoryBot.create(:sample)
			get :show, :study_subject_id => sample.study_subject.id,
				:id => sample.id, :format => 'pdf'
			assert_response :success
			assert_template 'show'
			assert_not_nil @response.headers['Content-Type']
			assert_match /application\/pdf/, @response.headers['Content-Type']
			assert_not_nil @response.headers['Content-Disposition']
			assert_match /inline/, @response.headers['Content-Disposition']
		end
	
		test "should show with #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :show, :study_subject_id => sample.study_subject_id, :id => sample.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'show'
		end

		test "should NOT show with mismatched study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample)
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id, :id => sample.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid study_subject_id #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :show, :study_subject_id => 0, :id => sample.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid id #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :show, :study_subject_id => sample.study_subject_id, :id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get index with #{cu} login and valid study_subject_id" do
			study_subject = FactoryBot.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end
	
		test "should NOT show with #{cu} login" do
			sample = FactoryBot.create(:sample)
			login_as send(cu)
			get :show, :study_subject_id => sample.study_subject_id, :id => sample.id
			assert_redirected_to root_path
		end

	end

	#	not logged in ..

	test "should NOT get index without login and valid study_subject_id" do
		study_subject = FactoryBot.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end
	
	test "should NOT get new sample without login" do
		study_subject = FactoryBot.create(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new sample without login" do
		study_subject = FactoryBot.create(:study_subject)
		assert_difference('Sample.count',0){
			post :create, :study_subject_id => study_subject.id,
				:sample => factory_attributes
		}
		assert_redirected_to_login
	end

	test "should NOT show without login" do
		sample = FactoryBot.create(:sample)
		get :show, :study_subject_id => sample.study_subject_id, :id => sample.id
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		sample = FactoryBot.create(:sample)
		get :edit, :study_subject_id => sample.study_subject_id, :id => sample.id
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		sample = FactoryBot.create(:sample, :updated_at => ( Time.now - 1.day ) )
		deny_changes("Sample.find(#{sample.id}).updated_at") {
			put :update, :study_subject_id => sample.study_subject_id, 
				:id => sample.id, :sample => {
					:external_id_source => 'trigger update'
				}
		}
		assert_redirected_to_login
	end

	test "should NOT destroy without login" do
		sample = FactoryBot.create(:sample)
		assert_difference('Sample.count',0){
			delete :destroy, :study_subject_id => sample.study_subject_id, 
				:id => sample.id
		}
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :sample,
		[ :project_id, :sample_type_id, :sent_to_subject_at, 
		:collected_from_subject_at, :shipped_to_ccls_at, :received_by_ccls_at, 
		:sent_to_lab_at, :organization_id, :received_by_lab_at, :sample_format, 
		:sample_temperature, :external_id, :external_id_source, :notes ],
		[:study_subject_id])

protected 

	def create_sample_with_subject(options={})
		s = FactoryBot.create(:study_subject, options)
		FactoryBot.create(:sample, :study_subject => s, :project => Project['ccls'])
	end

end
