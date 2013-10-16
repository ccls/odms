require 'test_helper'

class StudySubject::AddressingsControllerTest < ActionController::TestCase

	#	no route
	#	no study_subject_id
	#	no id
	assert_no_route(:get,:index)
	assert_no_route(:get,:show)
	assert_no_route(:get,:show,:id => 0)
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

#	NO SHOW OR INDEX ACTION

#	ASSERT_ACCESS_OPTIONS = {
#		:model => 'Addressing',
#		:actions => [:edit,:update],
#		:attributes_for_create => :factory_attributes,
#		:method_for_create => :create_addressing
#	}
#
#	assert_access_with_login({    :logins => site_editors })
#	assert_no_access_with_login({ :logins => non_site_editors })
#	assert_no_access_without_login

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:addressing,{
			:data_source_id => DataSource['unknown'].id
		}.merge(options))
	end

	def address_attributes(options={})
		{ 
			:address_attributes => FactoryGirl.attributes_for(
				:address, {
					:address_type_id => FactoryGirl.create(:address_type).id
				}.merge(options) 
			) 
		}
	end

	site_administrators.each do |cu|

		test "should destroy with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
#			assert_difference('Address.count',-1){
			assert_difference('Addressing.count',-1){
				delete :destroy, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id
			} #}
			assert_nil flash[:error]
			assert_redirected_to study_subject_contacts_path( addressing.study_subject_id )
pending "Doesn't destroy Address yet"
		end

		test "should NOT destroy with mismatched study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('Address.count',0){
			assert_difference('Addressing.count',0){
				delete :destroy, :study_subject_id => study_subject.id,
					:id => addressing.id
			} }
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			assert_difference('Address.count',0){
			assert_difference('Addressing.count',0){
				delete :destroy, :study_subject_id => 0,
					:id => addressing.id
			} }
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT destroy with invalid id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			assert_difference('Address.count',0){
			assert_difference('Addressing.count',0){
				delete :destroy, :study_subject_id => addressing.study_subject_id,
					:id => 0
			} }
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_administrators.each do |cu|
	
		test "should NOT destroy with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			delete :destroy, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_editors.each do |cu|

		test "should get new addressing with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert assigns(:addressing)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new addressing with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :new, :study_subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should create new addressing with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference("StudySubject.find(#{study_subject.id}).addressings.count",1) {
			assert_difference("StudySubject.find(#{study_subject.id}).addresses.count",1) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('AddressType.count',1) {
				post :create, :study_subject_id => study_subject.id,
					:addressing => factory_attributes(address_attributes)
			} } } } }
			assert assigns(:study_subject)
			assert_redirected_to study_subject_contacts_path(study_subject)
		end

#		test "should set verified_on on create if is_verified " <<
#				"with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as send(cu)
#			post :create, :study_subject_id => study_subject.id,
#				:addressing => factory_attributes(
#					:is_verified => true,
#					:how_verified => 'no idea'
#				)
#			assert assigns(:addressing)
#			assert_not_nil assigns(:addressing).verified_on
#		end
#
#		test "should set verified_by on create if is_verified " <<
#				"with #{cu} login" do
#			study_subject = FactoryGirl.create(:study_subject)
#			login_as u = send(cu)
#			post :create, :study_subject_id => study_subject.id,
#				:addressing => factory_attributes(
#					:is_verified => true,
#					:how_verified => 'no idea'
#				)
#			assert assigns(:addressing)
#			assert_not_nil assigns(:addressing).verified_by_uid
#			assert_equal assigns(:addressing).verified_by_uid, u.uid
#		end

		test "should NOT create new addressing with invalid study_subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :study_subject_id => 0, 
					:addressing => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT create new addressing with #{cu} login " <<
				"when create fails" do
			study_subject = FactoryGirl.create(:study_subject)
			Addressing.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:addressing => factory_attributes
			} }
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new addressing with #{cu} login " <<
				"and invalid addressing" do
			Addressing.any_instance.stubs(:valid?).returns(false)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:addressing => factory_attributes
			} }
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new addressing with #{cu} login " <<
				"and invalid address" do
			Address.any_instance.stubs(:create_or_update).returns(false)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:addressing => factory_attributes(address_attributes(
						:line_1 => nil
					))
			} }
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

#		test "should set verified_on on update if is_verified " <<
#				"with #{cu} login" do
#			addressing = FactoryGirl.create(:addressing)
#			login_as send(cu)
#			put :update, :study_subject_id => addressing.study_subject_id, 
#				:id => addressing.id,
#				:addressing => factory_attributes(
#					:is_verified  => true,
#					:how_verified => 'not a clue'
#				)
#			assert assigns(:addressing)
#			assert_not_nil assigns(:addressing).verified_on
#		end
#
#		test "should set verified_by on update if is_verified " <<
#				"with #{cu} login" do
#			addressing = FactoryGirl.create(:addressing)
#			login_as u = send(cu)
#			put :update, :study_subject_id => addressing.study_subject_id,
#				:id => addressing.id,
#				:addressing => factory_attributes(
#					:is_verified => true,
#					:how_verified => 'not a clue'
#				)
#			assert assigns(:addressing)
#			assert_not_nil assigns(:addressing).verified_by_uid
#			assert_equal assigns(:addressing).verified_by_uid, u.uid
#		end

		test "should NOT update addressing with #{cu} login " <<
				"when address update fails" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			Address.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id,
					:addressing => factory_attributes(address_attributes)
			}
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT update addressing with #{cu} login " <<
				"and invalid address" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			Address.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id,
					:addressing => factory_attributes(address_attributes(
						:line_1 => nil
					))
			}
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
				" if not residence address on update with #{cu} login" do
			addressing = FactoryGirl.create(:current_mailing_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',0) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => '1' }
			}
		end
	
		test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
				" if was not current address on update with #{cu} login" do
			addressing = FactoryGirl.create(:residence_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',0) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => '1' }
			}
		end
	
		test "should add 'subject_moved' event to subject if subject_moved is '1'" <<
				" on update with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',1) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => '1' }
			}
		end
	
		test "should not add 'subject_moved' event to subject if subject_moved is '0'" <<
				" on update with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',0) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => '0' }
			}
		end
	
		test "should add 'subject_moved' event to subject if subject_moved is 'true'" <<
				" on update with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',1) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => 'true' }
			}
		end
	
		test "should not add 'subject_moved' event to subject if subject_moved is 'false'" <<
				" on update with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',0) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => 'false' }
			}
		end
	
		test "should not add 'subject_moved' event to subject if subject_moved is nil" <<
				" on update with #{cu} login" do
			addressing = FactoryGirl.create(:current_residence_addressing)
			login_as send(cu)
			assert_difference('OperationalEvent.count',0) {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id, :addressing => {
					:current_address => '2',
					:subject_moved   => nil }
			}
		end

		test "should edit with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :edit, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_nil flash[:error]
		end

		test "should edit with latitude and longitude and #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			addressing.address.update_attributes(
				:latitude => -34.397, :longitude => 150.644)
			login_as send(cu)
			get :edit, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_nil flash[:error]
		end

		test "should NOT edit with mismatched study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :edit, :study_subject_id => study_subject.id,
				:id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :edit, :study_subject_id => 0,
				:id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT edit with invalid id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :edit, :study_subject_id => addressing.study_subject_id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should update with #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			assert_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id,
					:addressing => factory_attributes(:notes => 'trigger update')
			}
			assert_nil flash[:error]
			assert_redirected_to study_subject_contacts_path( addressing.study_subject_id )
		end

		test "should NOT update with save failure and #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			Addressing.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id,
					:addressing => factory_attributes(:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with invalid and #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			Addressing.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => addressing.id,
					:addressing => factory_attributes(:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_response :success
			assert_template 'edit'
		end

		test "should NOT update with mismatched study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => study_subject.id,
					:id => addressing.id,
					:addressing => factory_attributes(:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => 0,
					:id => addressing.id,
					:addressing => factory_attributes(:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT update with invalid id #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject_id,
					:id => 0,
					:addressing => factory_attributes(:notes => 'trigger update')
			}
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new addressing with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :new, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new addressing with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :study_subject_id => study_subject.id,
					:addressing => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT edit with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :edit, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT update with #{cu} login" do
			addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :study_subject_id => addressing.study_subject.id,
					:id => addressing.id,
					:addressing => factory_attributes
			}
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	site_readers.each do |cu|

		test "should get addressings with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert assigns(:study_subject)
			assert_response :success
			assert_template 'index'
		end



		test "should show with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :show, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
			assert assigns(:addressing)
			assert_response :success
			assert_template 'show'
			assert_nil flash[:error]
		end

		test "should show with latitude and longitude and #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			addressing.address.update_attributes(
				:latitude => -34.397, :longitude => 150.644)
			login_as send(cu)
			get :show, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
			assert assigns(:addressing)
			assert_response :success
			assert_template 'show'
			assert_nil flash[:error]
		end

		test "should NOT show with mismatched study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id,
				:id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid study_subject_id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :show, :study_subject_id => 0,
				:id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

		test "should NOT show with invalid id #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			login_as send(cu)
			get :show, :study_subject_id => addressing.study_subject_id,
				:id => 0
			assert_not_nil flash[:error]
			assert_redirected_to study_subjects_path
		end

	end

	non_site_readers.each do |cu|

		test "should NOT get addressings with #{cu} login" do
			study_subject = FactoryGirl.create(:study_subject)
			login_as send(cu)
			get :index, :study_subject_id => study_subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT show addressing with #{cu} login" do
			addressing = FactoryGirl.create(:addressing)
			study_subject = addressing.study_subject
			login_as send(cu)
			get :show, :study_subject_id => study_subject.id, :id => addressing.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	#	not logged in ..

	test "should NOT get addressings without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :index, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT get new addressing without login" do
		study_subject = FactoryGirl.create(:study_subject)
		get :new, :study_subject_id => study_subject.id
		assert_redirected_to_login
	end

	test "should NOT create new addressing without login" do
		study_subject = FactoryGirl.create(:study_subject)
		assert_difference('Addressing.count',0) {
		assert_difference('Address.count',0) {
			post :create, :study_subject_id => study_subject.id,
				:addressing => factory_attributes
		} }
		assert_redirected_to_login
	end

	test "should NOT edit without login" do
		addressing = FactoryGirl.create(:addressing)
		get :edit, :study_subject_id => addressing.study_subject_id,
			:id => addressing.id
		assert_redirected_to_login
	end

	test "should NOT update without login" do
		addressing = FactoryGirl.create(:addressing, :updated_at => ( Time.now - 1.day ) )
		deny_changes("Addressing.find(#{addressing.id}).updated_at") {
			put :update, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id, :addressing => factory_attributes
		}
		assert_redirected_to_login
	end

	test "should NOT destroy without login" do
		addressing = FactoryGirl.create(:addressing)
		assert_difference('Addressing.count',0) {
		assert_difference('Address.count',0) {
			delete :destroy, :study_subject_id => addressing.study_subject_id,
				:id => addressing.id
		} }
		assert_redirected_to_login
	end

protected

	def addressing_with_address(options={})
		FactoryGirl.attributes_for(:addressing, {
			:address_attributes => FactoryGirl.attributes_for(:address,{
				:address_type => AddressType['residence']
			}.merge(options[:address]||{}))
		}.merge(options[:addressing]||{}))
	end

	def ca_addressing(options={})
		addressing_with_address({
			:address => {:state => 'CA'}}.merge(options))
	end

	def az_addressing(options={})
		addressing_with_address({
			:address => {:state => 'AZ'}}.merge(options))
	end

end
