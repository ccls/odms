require 'test_helper'

class Api::IdentifiersControllerTest < ActionController::TestCase

	test "should get identifiers with credentials" do
		set_credentials
		identifier = create_identifier
		get :index
		assert_response :success
		assert assigns(:identifiers)
		assert assigns(:identifiers).include?(identifier)
	end

	test "should not get identifiers with http" do
		turn_https_off
		set_credentials
		get :index
		assert_response 302
		assert_response :redirect	#	to https
	end

	test "should not get identifiers without password" do
		set_credentials('admin')
		get :index
		assert_response 401
		assert_response :unauthorized
		#	action_controller/status_codes.rb
	end

	test "should not get identifiers with bad credentials" do
		set_credentials('foo','bar')
		get :index
		assert_response 401
		assert_response :unauthorized
		#	action_controller/status_codes.rb
	end

	test "should not get identifiers without credentials" do
		get :index
		assert_response 401
		assert_response :unauthorized
		#	action_controller/status_codes.rb
	end

#	test "should not gem homex identifier without id" do
#		set_credentials
#		assert_raise(ActionController::RoutingError){
#			get :show
#		}
#	end
#
#	test "should not gem homex identifier with invalid id" do
#		set_credentials
#		assert_raise(ActiveRecord::RecordNotFound){
#			get :show, :id => 0
#		}
#	end

protected 

	def set_credentials(*args)
		username, password = if args.empty?
			username_and_password
		else
			[ args[0], args[1] ]
		end
		@request.env['HTTP_AUTHORIZATION'
			] = ActionController::HttpAuthentication::Basic.encode_credentials(
				username, password)
	end

	def username_and_password
		config = YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/api.yml")).result)
		[ config[:user], config[:password] ]
	end

end
