require 'test_helper'

class StudySubject::AlternateContactsControllerTest < ActionController::TestCase

	#	First run can't first this out for some?
	tests StudySubject::AlternateContactsController

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

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:alternate_contact,{
		}.merge(options))
	end

	site_administrators.each do |cu|

		test "should destroy with #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			assert_difference('AlternateContact.count',-1){
				delete :destroy, :study_subject_id => alternate_contact.study_subject_id,
					:id => alternate_contact.id
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_contacts_path(alternate_contact.study_subject_id)
		end

		test "should NOT destroy with mismatched study_subject_id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('AlternateContact.count',0){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => alternate_contact.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid study_subject_id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			assert_difference('AlternateContact.count',0){
				delete :destroy, :study_subject_id => 0,
					:id => alternate_contact.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			assert_difference('AlternateContact.count',0){
				delete :destroy, :study_subject_id => alternate_contact.study_subject_id,
					:id => 0
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_administrators.each do |cu|

		test "should NOT destroy with #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			assert_difference('AlternateContact.count',0){
				delete :destroy, :study_subject_id => alternate_contact.study_subject_id,
					:id => alternate_contact.id
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_editors.each do |cu|

		test "should get new alternate_contact with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert assigns(:alternate_contact)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new alternate_contact with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new alternate_contact with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference("StudySubject.find(#{study_subject.id}).alternate_contacts.count",1) {
			assert_difference('AlternateContact.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:alternate_contact => factory_attributes(:relation => 'testing')
			} }
			assert assigns(:study_subject)
			assert_redirected_to study_subject_contacts_path(study_subject)
		end

		test "should NOT create new alternate_contact with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			assert_difference('AlternateContact.count',0) do
				post :create, :study_subject_id => 0, 
					:alternate_contact => factory_attributes
			end
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create new alternate_contact with #{cu} login when " <<
				"create fails" do
			study_subject = FactoryGirl.create(:study_subject)
			AlternateContact.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('AlternateContact.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:alternate_contact => factory_attributes(:relation => 'testing')
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new alternate_contact with #{cu} login " <<
				"and invalid alternate_contact" do
			study_subject = FactoryGirl.create(:study_subject)
			AlternateContact.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			assert_difference('AlternateContact.count',0) do
				post :create, :study_subject_id => study_subject.id,
					:alternate_contact => factory_attributes(:relation => 'testing')
			end
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should edit with #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			get :edit, :study_subject_id => alternate_contact.study_subject_id,
				:id => alternate_contact.id
			assert_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT edit with mismatched study_subject_id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => alternate_contact.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid study_subject_id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			get :edit, :study_subject_id => 0,
				:id => alternate_contact.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			get :edit, :study_subject_id => alternate_contact.study_subject_id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update with #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => alternate_contact.study_subject_id,
					:id => alternate_contact.id, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_contacts_path(alternate_contact.study_subject_id)
		end

		test "should NOT update with save failure and #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			AlternateContact.any_instance.stubs(:create_or_update).returns(false)
			deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => alternate_contact.study_subject_id,
					:id => alternate_contact.id, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with invalid and #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			AlternateContact.any_instance.stubs(:valid?).returns(false)
			deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => alternate_contact.study_subject_id,
					:id => alternate_contact.id, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with mismatched study_subject_id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => alternate_contact.id, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid study_subject_id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:id => alternate_contact.id, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid id #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => alternate_contact.study_subject_id,
					:id => 0, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new alternate_contact with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new alternate_contact with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('AlternateContact.count',0){
				post :create, :study_subject_id => study_subject.id,
					:alternate_contact => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact)
			login_as send(cu)
			get :edit, :study_subject_id => alternate_contact.study_subject_id,
				:id => alternate_contact.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
				put :update, :study_subject_id => alternate_contact.study_subject_id,
					:id => alternate_contact.id, :alternate_contact => {
						:phone_number_1 => '1234567890'
					}
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

		test "should get alternate_contacts with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get alternate_contacts with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get alternate_contacts without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new alternate_contact without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new alternate_contact without login" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_difference('AlternateContact.count',0){
			post :create, :study_subject_id => study_subject.id,
				:alternate_contact => factory_attributes
		}
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		alternate_contact = FactoryGirl.create(:alternate_contact)
		get :edit, :study_subject_id => alternate_contact.study_subject_id,
			:id => alternate_contact.id
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		alternate_contact = FactoryGirl.create(:alternate_contact, :updated_at => ( Time.now - 1.day ) )
		deny_changes("AlternateContact.find(#{alternate_contact.id}).updated_at") {
			put :update, :study_subject_id => alternate_contact.study_subject_id,
				:id => alternate_contact.id, :alternate_contact => {
					:phone_number_1 => '1234567890'
				}
		}
		assert_redirected_to_login
	end

	test "should NOT destroy without login" do
		alternate_contact = FactoryGirl.create(:alternate_contact)
		assert_difference('AlternateContact.count',0){
			delete :destroy, :study_subject_id => alternate_contact.study_subject_id,
				:id => alternate_contact.id
		}
		assert_redirected_to_login
	end

	add_strong_parameters_tests( :alternate_contact,
		[ :name, :relation, :line_1, :line_2, :city, :state, :zip, 
			:phone_number_1, :phone_number_2 ],
		[:study_subject_id])

end
