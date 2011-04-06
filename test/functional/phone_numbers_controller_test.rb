require 'test_helper'

class PhoneNumbersControllerTest < ActionController::TestCase

	#	no subject_id
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

	ASSERT_ACCESS_OPTIONS = {
		:model => 'PhoneNumber',
		:actions => [:edit,:update],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_phone_number
	}
	def factory_attributes(options={})
		Factory.attributes_for(:phone_number,{
			:phone_type_id => Factory(:phone_type).id
		}.merge(options))
	end

	assert_access_with_login({ 
		:logins => [:superuser,:admin,:editor] })
	assert_no_access_with_login({ 
		:logins => [:interviewer,:reader,:active_user] })
	assert_no_access_without_login


	#	destroy is TEMPORARY
	assert_access_with_login(
		:actions => [:destroy],
		:login => :superuser
	)


%w( superuser admin editor ).each do |cu|

	test "should get new phone_number with #{cu} login" do
		subject = create_subject	#	Factory(:subject)
		login_as send(cu)
		get :new, :subject_id => subject.id
		assert assigns(:subject)
		assert assigns(:phone_number)
		assert_response :success
		assert_template 'new'
	end

	test "should NOT get new phone_number with invalid subject_id " <<
			"and #{cu} login" do
		login_as send(cu)
		get :new, :subject_id => 0
		assert_not_nil flash[:error]
		assert_redirected_to subjects_path
	end

	test "should create new phone_number with #{cu} login" do
		subject = create_subject	#	Factory(:subject)
		login_as send(cu)
		assert_difference("Subject.find(#{subject.id}).phone_numbers.count",1) {
		assert_difference('PhoneNumber.count',1) {
			post :create, :subject_id => subject.id,
				:phone_number => factory_attributes
		} }
		assert assigns(:subject)
		assert_redirected_to subject_contacts_path(subject)
	end

	test "should set verified_on on create if is_verified " <<
			"with #{cu} login" do
		subject = create_subject	#	Factory(:subject)
		login_as send(cu)
		post :create, :subject_id => subject.id,
			:phone_number => factory_attributes(
				:is_verified => true,
				:how_verified => 'no idea'
			)
		assert assigns(:phone_number)
		assert_not_nil assigns(:phone_number).verified_on
	end

	test "should set verified_by on create if is_verified " <<
			"with #{cu} login" do
		subject = create_subject	#	Factory(:subject)
		login_as u = send(cu)
		post :create, :subject_id => subject.id,
			:phone_number => factory_attributes(
				:is_verified => true,
				:how_verified => 'no idea'
			)
		assert assigns(:phone_number)
		assert_not_nil assigns(:phone_number).verified_by_id
		assert_equal assigns(:phone_number).verified_by_id, u.id
	end

	test "should NOT create new phone_number with invalid subject_id " <<
			"and #{cu} login" do
		login_as send(cu)
		assert_difference('PhoneNumber.count',0) do
			post :create, :subject_id => 0, 
				:phone_number => factory_attributes
		end
		assert_not_nil flash[:error]
		assert_redirected_to subjects_path
	end

	test "should NOT create new phone_number with #{cu} login when " <<
			"create fails" do
		subject = create_subject	#	Factory(:subject)
		PhoneNumber.any_instance.stubs(:create_or_update).returns(false)
		login_as send(cu)
		assert_difference('PhoneNumber.count',0) do
			post :create, :subject_id => subject.id,
				:phone_number => factory_attributes
		end
		assert assigns(:subject)
		assert_response :success
		assert_template 'new'
		assert_not_nil flash[:error]
	end

	test "should NOT create new phone_number with #{cu} login " <<
			"and invalid phone_number" do
		subject = create_subject	#	Factory(:subject)
		PhoneNumber.any_instance.stubs(:valid?).returns(false)
		login_as send(cu)
		assert_difference('PhoneNumber.count',0) do
			post :create, :subject_id => subject.id,
				:phone_number => factory_attributes
		end
		assert assigns(:subject)
		assert_response :success
		assert_template 'new'
		assert_not_nil flash[:error]
	end


	test "should edit phone_number with #{cu} login" do
		phone_number = create_phone_number
		login_as send(cu)
		get :edit, :id => phone_number.id
		assert assigns(:phone_number)
		assert_response :success
		assert_template 'edit'
	end

	test "should NOT edit phone_number with invalid id and #{cu} login" do
		phone_number = create_phone_number
		login_as send(cu)
		get :edit, :id => 0
		assert_redirected_to subjects_path
	end

	test "should update phone_number with #{cu} login" do
		phone_number = create_phone_number(
			:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		assert_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
			put :update, :id => phone_number.id,
				:phone_number => factory_attributes
		}
		assert assigns(:phone_number)
		assert_redirected_to subject_contacts_path(phone_number.subject)
	end

	test "should set verified_on on update if is_verified " <<
			"with #{cu} login" do
		phone_number = create_phone_number
		login_as send(cu)
		put :update, :id => phone_number.id,
			:phone_number => factory_attributes(
				:is_verified  => true,
				:how_verified => 'not a clue'
			)
		assert assigns(:phone_number)
		assert_not_nil assigns(:phone_number).verified_on
	end

	test "should set verified_by on update if is_verified " <<
			"with #{cu} login" do
		phone_number = create_phone_number
		login_as u = send(cu)
		put :update, :id => phone_number.id,
			:phone_number => factory_attributes(
				:is_verified => true,
				:how_verified => 'not a clue'
			)
		assert assigns(:phone_number)
		assert_not_nil assigns(:phone_number).verified_by_id
		assert_equal assigns(:phone_number).verified_by_id, u.id
	end

	test "should NOT update phone_number with invalid id and #{cu} login" do
		phone_number = create_phone_number(
			:updated_at => Chronic.parse('yesterday'))
		login_as send(cu)
		deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
			put :update, :id => 0,
				:phone_number => factory_attributes
		}
		assert_redirected_to subjects_path
	end

	test "should NOT update phone_number with #{cu} login " <<
			"when update fails" do
		phone_number = create_phone_number(
			:updated_at => Chronic.parse('yesterday'))
		PhoneNumber.any_instance.stubs(:create_or_update).returns(false)
		login_as send(cu)
		deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
			put :update, :id => phone_number.id,
				:phone_number => factory_attributes
		}
		assert assigns(:phone_number)
		assert_response :success
		assert_template 'edit'
		assert_not_nil flash[:error]
	end

	test "should NOT update phone_number with #{cu} login " <<
			"and invalid phone_number" do
		phone_number = create_phone_number(
			:updated_at => Chronic.parse('yesterday'))
		PhoneNumber.any_instance.stubs(:valid?).returns(false)
		login_as send(cu)
		deny_changes("PhoneNumber.find(#{phone_number.id}).updated_at") {
			put :update, :id => phone_number.id,
				:phone_number => factory_attributes
		}
		assert assigns(:phone_number)
		assert_response :success
		assert_template 'edit'
		assert_not_nil flash[:error]
	end

end


%w( interviewer reader active_user ).each do |cu|

	test "should NOT get new phone_number with #{cu} login" do
		subject = create_subject	#	Factory(:subject)
		login_as send(cu)
		get :new, :subject_id => subject.id
		assert_not_nil flash[:error]
		assert_redirected_to root_path
	end

	test "should NOT create new phone_number with #{cu} login" do
		subject = create_subject	#	Factory(:subject)
		login_as send(cu)
		post :create, :subject_id => subject.id,
			:phone_number => factory_attributes
		assert_not_nil flash[:error]
		assert_redirected_to root_path
	end

end

	test "should NOT get new phone_number without login" do
		subject = create_subject	#	Factory(:subject)
		get :new, :subject_id => subject.id
		assert_redirected_to_login
	end

	test "should NOT create new phone_number without login" do
		subject = create_subject	#	Factory(:subject)
		post :create, :subject_id => subject.id,
			:phone_number => factory_attributes
		assert_redirected_to_login
	end

end
