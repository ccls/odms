require 'test_helper'

class StudySubject::PhoneNumbersControllerTest < ActionController::TestCase

	#	no study_subject_id
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

	#	no route
	assert_no_route(:get,:index)
	assert_no_route(:get,:show)
	assert_no_route(:get,:show,:id => 0)

#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'PhoneNumber',
#		:actions => [:edit,:update],	#	only shallow routes
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_phone_number
#	}
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:phone_number,{
			:data_source_id => DataSource['unknown'].id,
			:phone_type     => 'Unknown'
		}.merge(options))
	end

	site_administrators.each do |cu|

		test "should destroy with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			assert_difference('PhoneNumber.count',-1){
				delete :destroy, :study_subject_id => phone_number.study_subject_id,
					:id => phone_number.id
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_contacts_path(phone_number.study_subject_id)
		end

		test "should NOT destroy with mismatched study_subject_id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => phone_number.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid study_subject_id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0){
				delete :destroy, :study_subject_id => 0,
					:id => phone_number.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0){
				delete :destroy, :study_subject_id => phone_number.study_subject_id,
					:id => 0
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT destroy with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0){
				delete :destroy, :study_subject_id => phone_number.study_subject_id,
					:id => phone_number.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_editors.each do |cu|

		test "should get new phone_number with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert assigns(:phone_number)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new phone_number with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new phone_number with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference("StudySubject.find(#{study_subject.id}).phone_numbers.count",1) {
			assert_difference('PhoneNumber.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:phone_number => factory_attributes
			} }
			assert assigns(:study_subject)
			assert_redirected_to study_subject_contacts_path(study_subject)
		end

#		test "should set verified_on on create if is_verified " <<
#				"with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as send(cu)
#			post :create, :study_subject_id => study_subject.id,
#				:phone_number => factory_attributes(
#					:is_verified => true,
#					:how_verified => 'no idea'
#				)
#			assert assigns(:phone_number)
#			assert_not_nil assigns(:phone_number).verified_on
#		end
#
#		test "should set verified_by on create if is_verified " <<
#				"with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as u = send(cu)
#			post :create, :study_subject_id => study_subject.id,
#				:phone_number => factory_attributes(
#					:is_verified => true,
#					:how_verified => 'no idea'
#				)
#			assert assigns(:phone_number)
#			assert_not_nil assigns(:phone_number).verified_by_uid
#			assert_equal assigns(:phone_number).verified_by_uid, u.uid
#		end

		test "should NOT create new phone_number with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			assert_difference('PhoneNumber.count',0) do
				post :create, :study_subject_id => 0, 
					:phone_number => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create new phone_number with #{cu} login when " <<
				"create fails" do
			study_subject = FactoryGirl.create(:study_subject)
			PhoneNumber.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:phone_number => factory_attributes
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new phone_number with #{cu} login " <<
				"and invalid phone_number" do
			study_subject = FactoryGirl.create(:study_subject)
			PhoneNumber.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:phone_number => factory_attributes
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

#		test "should set verified_on on update if is_verified " <<
#				"with #{cu} login" do
#			phone_number = FactoryGirl.create(:phone_number)
#			login_as send(cu)
#			put :update, :study_subject_id => phone_number.study_subject_id,
#				:id => phone_number.id,
#				:phone_number => factory_attributes(
#					:is_verified  => true,
#					:how_verified => 'not a clue'
#				)
#			assert assigns(:phone_number)
#			assert_not_nil assigns(:phone_number).verified_on
#		end
#
#		test "should set verified_by on update if is_verified " <<
#				"with #{cu} login" do
#			phone_number = FactoryGirl.create(:phone_number)
#			login_as u = send(cu)
#			put :update, :study_subject_id => phone_number.study_subject_id,
#				:id => phone_number.id,
#				:phone_number => factory_attributes(
#					:is_verified => true,
#					:how_verified => 'not a clue'
#				)
#			assert assigns(:phone_number)
#			assert_not_nil assigns(:phone_number).verified_by_uid
#			assert_equal assigns(:phone_number).verified_by_uid, u.uid
#		end

		test "should edit with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			get :edit, :study_subject_id => phone_number.study_subject_id,
				:id => phone_number.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit with mismatched study_subject_id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => phone_number.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid study_subject_id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			get :edit, :study_subject_id => 0,
				:id => phone_number.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			get :edit, :study_subject_id => phone_number.study_subject_id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => phone_number.study_subject_id,
					:id => phone_number.id, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_contacts_path(phone_number.study_subject_id)
		end

		test "should NOT update with save failure and #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			PhoneNumber.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => phone_number.study_subject_id,
					:id => phone_number.id, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with invalid and #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			PhoneNumber.any_instance.stubs(:valid?).returns(false)
			deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => phone_number.study_subject_id,
					:id => phone_number.id, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with mismatched study_subject_id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => phone_number.id, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid study_subject_id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:id => phone_number.id, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid id #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => phone_number.study_subject_id,
					:id => 0, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new phone_number with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new phone_number with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('PhoneNumber.count',0){
				post :create, :study_subject_id => study_subject.id,
					:phone_number => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number)
			login_as send(cu)
			get :edit, :study_subject_id => phone_number.study_subject_id,
				:id => phone_number.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
				put :update, :study_subject_id => phone_number.study_subject_id,
					:id => phone_number.id, :phone_number => {
						:phone_number => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

		test "should get phone_numbers with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get phone_numbers with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get phone_numbers without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new phone_number without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new phone_number without login" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_difference('PhoneNumber.count',0){
			post :create, :study_subject_id => study_subject.id,
				:phone_number => factory_attributes
		}
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		phone_number = FactoryGirl.create(:phone_number)
		get :edit, :study_subject_id => phone_number.study_subject_id,
			:id => phone_number.id
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		phone_number = FactoryGirl.create(:phone_number, :updated_at => ( Time.now - 1.day ) )
		deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
			put :update, :study_subject_id => phone_number.study_subject_id,
				:id => phone_number.id, :phone_number => {
					:phone_number => '1234567890'
				}
		}
		assert_redirected_to_login
	end

	test "should NOT destroy without login" do
		phone_number = FactoryGirl.create(:phone_number)
		assert_difference('PhoneNumber.count',0){
			delete :destroy, :study_subject_id => phone_number.study_subject_id,
				:id => phone_number.id
		}
		assert_redirected_to_login
	end

end
