require 'test_helper'

class AddressingsControllerTest < ActionController::TestCase

	#	no route
	assert_no_route(:get,:index)
	assert_no_route(:get,:show)
	assert_no_route(:get,:show,:id => 0)

	#	no subject_id
	assert_no_route(:get,:new)
	assert_no_route(:post,:create)

	#	no id
	assert_no_route(:get,:edit)
	assert_no_route(:put,:update)
	assert_no_route(:delete,:destroy)

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Addressing',
		:actions => [:edit,:update],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_addressing
	}

	def factory_attributes(options={})
		Factory.attributes_for(:addressing,options)
	end

	def address_attributes(options={})
		{ 
			:address_attributes => Factory.attributes_for(
				:address, {
					:address_type_id => Factory(:address_type).id
				}.merge(options) 
			) 
		}
	end

	assert_access_with_login({ 
		:logins => site_editors })
	assert_no_access_with_login({ 
		:logins => non_site_editors })
	assert_no_access_without_login

	#	destroy is TEMPORARY
	assert_access_with_login(
		:actions => [:destroy],
		:login => :superuser
	)


	site_editors.each do |cu|

		test "should get new addressing with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			get :new, :subject_id => subject.id
			assert assigns(:subject)
			assert assigns(:addressing)
			assert_response :success
			assert_template 'new'
		end

		test "should NOT get new addressing with invalid subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			get :new, :subject_id => 0
			assert_not_nil flash[:error]
			assert_redirected_to subjects_path
		end

		test "should make subject ineligible after create " <<
				"with #{cu} login" do
			subject = create_eligible_hx_subject
			login_as send(cu)
			assert_difference("Subject.find(#{subject.id}).addressings.count",1) {
			assert_difference("Subject.find(#{subject.id}).addresses.count",1) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
				post :create, :subject_id => subject.id,
					:addressing => az_addressing()
			} } } }
			assert assigns(:subject)
			subject.hx_enrollment.reload	#	NEEDED
			assert_subject_is_not_eligible(subject)
			assert_equal   subject.hx_enrollment.ineligible_reason,
				IneligibleReason['newnonCA']
			assert_redirected_to subject_contacts_path(subject)
		end

		test "should create new addressing with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			assert_difference("Subject.find(#{subject.id}).addressings.count",1) {
			assert_difference("Subject.find(#{subject.id}).addresses.count",1) {
			assert_difference('Addressing.count',1) {
			assert_difference('Address.count',1) {
			assert_difference('AddressType.count',1) {
				post :create, :subject_id => subject.id,
					:addressing => factory_attributes(address_attributes)
			} } } } }
			assert assigns(:subject)
			assert_redirected_to subject_contacts_path(subject)
		end

		test "should set verified_on on create if is_verified " <<
				"with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			post :create, :subject_id => subject.id,
				:addressing => factory_attributes(
					:is_verified => true,
					:how_verified => 'no idea'
				)
			assert assigns(:addressing)
			assert_not_nil assigns(:addressing).verified_on
		end

		test "should set verified_by on create if is_verified " <<
				"with #{cu} login" do
			subject = Factory(:subject)
			login_as u = send(cu)
			post :create, :subject_id => subject.id,
				:addressing => factory_attributes(
					:is_verified => true,
					:how_verified => 'no idea'
				)
			assert assigns(:addressing)
			assert_not_nil assigns(:addressing).verified_by_id
			assert_equal assigns(:addressing).verified_by_id, u.id
		end

		test "should NOT create new addressing with invalid subject_id " <<
				"and #{cu} login" do
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :subject_id => 0, 
					:addressing => factory_attributes
			} }
			assert_not_nil flash[:error]
			assert_redirected_to subjects_path
		end

		test "should NOT create new addressing with #{cu} login " <<
				"when create fails" do
			subject = Factory(:subject)
			Addressing.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :subject_id => subject.id,
					:addressing => factory_attributes
			} }
			assert assigns(:subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new addressing with #{cu} login " <<
				"and invalid addressing" do
			Addressing.any_instance.stubs(:valid?).returns(false)
			subject = Factory(:subject)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :subject_id => subject.id,
					:addressing => factory_attributes
			} }
			assert assigns(:subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

		test "should NOT create new addressing with #{cu} login " <<
				"and invalid address" do
	#		Address.any_instance.stubs(:valid?).returns(false)
			Address.any_instance.stubs(:create_or_update).returns(false)
			subject = Factory(:subject)
			login_as send(cu)
			assert_difference('Addressing.count',0) {
			assert_difference('Address.count',0) {
				post :create, :subject_id => subject.id,
					:addressing => factory_attributes(address_attributes(
						:line_1 => nil
					))
			} }
			assert assigns(:subject)
			assert_response :success
			assert_template 'new'
			assert_not_nil flash[:error]
		end

#	TODO duplicate?
		test "should edit addressing with #{cu} login" do
			addressing = create_addressing
			login_as send(cu)
			get :edit, :id => addressing.id
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
		end

#	TODO duplicate?
		test "should NOT edit addressing with invalid id and #{cu} login" do
			addressing = create_addressing
			login_as send(cu)
			get :edit, :id => 0
			assert_redirected_to subjects_path
		end

#	TODO duplicate?
		test "should update addressing with #{cu} login" do
			addressing = create_addressing(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			assert_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :id => addressing.id,
					:addressing => factory_attributes
			}
			assert assigns(:addressing)
			assert_redirected_to subject_contacts_path(addressing.subject)
		end

		test "should set verified_on on update if is_verified " <<
				"with #{cu} login" do
			addressing = create_addressing
			login_as send(cu)
			put :update, :id => addressing.id,
				:addressing => factory_attributes(
					:is_verified  => true,
					:how_verified => 'not a clue'
				)
			assert assigns(:addressing)
			assert_not_nil assigns(:addressing).verified_on
		end

		test "should set verified_by on update if is_verified " <<
				"with #{cu} login" do
			addressing = create_addressing
			login_as u = send(cu)
			put :update, :id => addressing.id,
				:addressing => factory_attributes(
					:is_verified => true,
					:how_verified => 'not a clue'
				)
			assert assigns(:addressing)
			assert_not_nil assigns(:addressing).verified_by_id
			assert_equal assigns(:addressing).verified_by_id, u.id
		end

#	TODO duplicate?
		test "should NOT update addressing with invalid id and #{cu} login" do
			addressing = create_addressing(:updated_at => Chronic.parse('yesterday'))
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :id => 0,
					:addressing => factory_attributes
			}
			assert_redirected_to subjects_path
		end

#	TODO duplicate?
		test "should NOT update addressing with #{cu} login " <<
				"when addressing update fails" do
			addressing = create_addressing(:updated_at => Chronic.parse('yesterday'))
			Addressing.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :id => addressing.id,
					:addressing => factory_attributes
			}
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT update addressing with #{cu} login " <<
				"when address update fails" do
			addressing = create_addressing(:updated_at => Chronic.parse('yesterday'))
			Address.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :id => addressing.id,
					:addressing => factory_attributes(address_attributes)
			}
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

#	TODO duplicate?
		test "should NOT update addressing with #{cu} login " <<
				"and invalid addressing" do
			addressing = create_addressing(:updated_at => Chronic.parse('yesterday'))
			Addressing.any_instance.stubs(:valid?).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :id => addressing.id,
					:addressing => factory_attributes
			}
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

		test "should NOT update addressing with #{cu} login " <<
				"and invalid address" do
			addressing = create_addressing(:updated_at => Chronic.parse('yesterday'))
			Address.any_instance.stubs(:create_or_update).returns(false)
			login_as send(cu)
			deny_changes("Addressing.find(#{addressing.id}).updated_at") {
				put :update, :id => addressing.id,
					:addressing => factory_attributes(address_attributes(
						:line_1 => nil
					))
			}
			assert assigns(:addressing)
			assert_response :success
			assert_template 'edit'
			assert_not_nil flash[:error]
		end

	end

	non_site_editors.each do |cu|

		test "should NOT get new addressing with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			get :new, :subject_id => subject.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

		test "should NOT create new addressing with #{cu} login" do
			subject = Factory(:subject)
			login_as send(cu)
			post :create, :subject_id => subject.id,
				:addressing => factory_attributes
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT get new addressing without login" do
		subject = Factory(:subject)
		get :new, :subject_id => subject.id
		assert_redirected_to_login
	end

	test "should NOT create new addressing without login" do
		subject = Factory(:subject)
		post :create, :subject_id => subject.id,
			:addressing => factory_attributes
		assert_redirected_to_login
	end

protected


	def addressing_with_address(options={})
		Factory.attributes_for(:addressing, {
			:address_attributes => Factory.attributes_for(:address,{
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
