require 'test_helper'
require 'integration_test_helper'

class BasicUserAndSessionTest < ActionController::IntegrationTest

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

##	gotta figure out how to use integration tests to ensure that the forms contain
##	all of the necessary attributes to create and update valid records.
##	User login is a stumbling block, so let's see if I can get it to work.
##	Being that this is calnet makes it particularly challenging.
##	This really sucks.  Why is it so different than the other tests?
##	Everything needs to be prefixed by @session.  This is irritating.
#
	all_test_roles.each do |cu|

		test "should get #{cu} info with #{cu} login" do
			u = send(cu)
			login_as u
			get user_path(u), {}, { 'HTTPS' => 'on' }
			assert_response :success
			assert_not_nil assigns(:user)
			assert_equal u, assigns(:user)
		end

		test "should not get #{cu} info if not logged in" do
			u = send(cu)
			get user_path(u), {}, { 'HTTPS' => 'on' }
			assert_redirected_to_login

			@session.get user_path(u)
			@session.assert_response :redirect
			assert_match "https://auth-test.berkeley.edu/cas/login",
				@session.response.redirected_to
		end

	end

	site_administrators.each do |cu|

		test "should edit a page with #{cu} login" do
			user = send(cu)
			assert Page.count > 0
			page = Page.first
			login_as user
			get edit_page_path(page), {}, { 'HTTPS' => 'on' }
			assert_response :success
		end

		test "should edit and update a page with #{cu} login using webrat" do
			user = send(cu)
			assert Page.count > 0
			page = Page.first
			login_as user

			#	need to set HTTPS for webrat
			header('HTTPS', 'on')
			visit edit_page_path(page)
			fill_in "page[menu_en]", :with => "MyNewMenu"

			#	click_button(value)
			click_button "Update"	
# <p>
#  <input name="commit" type="submit" value="Update" />&nbsp;
#  <a href="/pages/1/edit" class=" submit button">Update</a>
#  <a href="/pages/1" class="button">Cancel and View</a>
# </p>


#	How to click a javascript window button?  Some of these forms have a confirm pop-up.
#			click_button "OK"	
#	id="edit_page_1" 
#		submit_form(id)	#	probably use this rather than click_button for those that have javascript confirm windows
#			submit_form 'edit_page'

#	this is actually redirected, but it actually wouldn't test that way as the redirect is followed.
#			assert_redirected_to page_path(page)	

#	puts @response.body	#	is actually page_path(page)

			assert_not_nil flash[:notice]
			assert_response :success
		end

	end

end

__END__

webrat

  def test_trial_account_sign_up
    visit home_path
    click_link "Sign up"
    fill_in "Email", :with => "good@example.com"
    select "Free account"
    click_button "Register"
  end

