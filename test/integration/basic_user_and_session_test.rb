require 'test_helper'

class BasicUserAndSessionTest < ActionController::IntegrationTest
	include CalnetAuthenticated::TestHelper

	fixtures :all

	def setup
#		@session = ActionController::Integration::Session.new
#	either way
		@session = open_session
		assert !@session.https?
		@session.https!
		assert @session.https?

#	I may not need all this extra session stuff if I mimic the functional styling ...


#	needed if using calnet_authenticated's login
#	unfortunately, this @request is not the same 
#		@request = ActionController::TestRequest.new

#@session.send(:request=, @request)
#@session.instance_variable_set('@request', @request)
####@session.instance_variable_set('@request', ActionController::TestRequest.new)

#	can't do this
#		@session.request = @request

#	However, I think that webrat may need it all, so just commenting it out for now.
#	may want to review from line 615
#/usr/lib/ruby/gems/1.8/gems/actionpack-2.3.14/lib/action_controller/integration.rb
	end

	test "should get home page if not logged in" do
#		@session.get( root_path() )
#		assert_nil @session.flash[:error]
#		@session.assert_response :success
		#
		#	either way, as session is irrelevant here
		#
		get root_path(), {}, { 'HTTPS' => 'on' }
		assert_nil flash[:error]
		assert_response :success
	end

	test "should not get user profile if not logged in" do
		u = administrator
		get user_path(u), {}, { 'HTTPS' => 'on' }
		assert_redirected_to_login

#		@session.get user_path(u)
#		@session.assert_response :redirect
#		assert_match "https://auth-test.berkeley.edu/cas/login",
#			@session.response.redirected_to


#		@session.assert_redirected_to_login
#puts @response.request.methods.sort
#puts @response.redirected_to
#	https://auth-test.berkeley.edu/cas/login?service=https%3A%2F%2Fwww.example.com%2Fusers%2F1
#puts @response.methods.sort
#		flunk
	end

	test "user should login and view own profile" do
#	gotta figure out how to use integration tests to ensure that the forms contain
#	all of the necessary attributes to create and update valid records.
#	User login is a stumbling block, so let's see if I can get it to work.
#	Being that this is calnet makes it particularly challenging.
#	This really sucks.  Why is it so different than the other tests?
#	Everything needs to be prefixed by @session.  This is irritating.

		u = administrator
		login_as u
#puts u.role_names
#puts u.is_user?(u)
#puts u.may_administrate?

#	current_user doesn't work right because session isn't set properly here
#	this session crap sucks.

		get users_path, {}, { 'HTTPS' => 'on' }
		assert_response :success
		get user_path(u), {}, { 'HTTPS' => 'on' }
		assert_response :success
	
	end

protected

#	login is the only thing that really needs a session?

	def login_as( user=nil )
		uid = ( user.is_a?(User) ) ? user.uid : user
		if !uid.blank?
#assert_not_nil @session

#assert_not_nil @session.cookies
#puts @session.cookies

#NoMethodError: undefined method `session' for nil:NilClass			#	What???
#assert_not_nil @session.session

#	This should be ...
#  session.session.data # a populated session hash

#puts @session.session.methods.sort
#assert_not_nil @session.data
#			@session.session[:calnetuid] = uid					#	how do I do this in integration testing????????


#	Here, this is NOT the same session that the controller sees.
#	So setting this does NOT set the current_user as it does in functional testing.
#	Apparently, there is supposed to be a 
#			@session.session.data[:calnetuid] = uid
#	@request is nil in TestProcess so when @request.session is called it fails

			#	What a hack.  Create a fake $session and fake methods to read and write it.
			#	All I wanted to do was manually set a session key and this is what it came down to.
			#	I couldn't even stub out current_user!
#			$session ||= HashWithIndifferentAccess.new
#			$session[:calnetuid] = uid					#	how do I do this in integration testing????????


#			@request.session[:calnetuid] = uid					#	how do I do this in integration testing????????
#puts			@session.request.session.class
#			@session.request.session[:calnetuid] = uid					#	how do I do this in integration testing????????

#ActionController::Session::AbstractStore::SessionHash

			stub_ucb_ldap_person()
			u = User.find_create_and_update_by_uid(uid)

			#	Rather than manually manipulate the session,
			#	I created a fake controller to do it.
			#	Still not using the @session provided by integration testing (open_session)
			post fake_session_path(), { :id => u.id }, { 'HTTPS' => 'on' }

#			ActionController::Base.any_instance.stubs(:current_user).returns(u)

			CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
		end
	end

end

#class ActionController::Base
#		def current_user
#			load 'user.rb' unless defined?(User)
#			@current_user ||= if( $session && $session[:calnetuid] )
#					User.find_create_and_update_by_uid($session[:calnetuid])
#				else
#					nil
#				end
#		end
#end


__END__

ActiveSupport::TestCase.send(:include,CalnetAuthenticated::TestHelper)

from calnet_authenticated/test/functional/calnet/users_controller_test.rb

... class Calnet::UsersControllerTest < ActionController::TestCase

	all_test_roles.each do |cu|
		test "should get #{cu} info with self login" do
			u = send(cu)
			login_as u
			get :show, :id => u.id
			assert_response :success
			assert_not_nil assigns(:user)
			assert_equal u, assigns(:user)
		end
	end



calnet test_helper


	def assert_redirected_to_login
		assert_response :redirect
		assert_match "https://auth-test.berkeley.edu/cas/login",
			@response.redirected_to
	end

