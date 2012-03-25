require 'test_helper'

class ActiveScaffold::AddressesControllerTest < ActionController::TestCase

#	def setup
		#	We can skip the after_filter in setup, but not in the test itself.
		#	@controller.class.skip_after_filter :validate_page
		#	Or stub should_validate? in the test.
		#	Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)
#	end

	site_administrators.each do |cu|

		test "should get index with #{cu} login" do
			#	active_scaffold pages won't be 100% valid html.
			Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)
			login_as send(cu)
			get :index
			assert_response :success
		end
	
	end

#
#	I am more interested that the following will NOT happen 
#	rather than the prior will.  Below are all of the
#	ActiveScaffold and RESTful routes, none of which should
#	work for anyone other that administrators.
#

	non_site_administrators.each do |cu|

		test "should NOT get index with #{cu} login" do
			login_as send(cu)
			get :index
			assert_redirected_to root_path
		end

	end

	test "should NOT get index without login" do
		get :index
		assert_redirected_to_login
	end

end
