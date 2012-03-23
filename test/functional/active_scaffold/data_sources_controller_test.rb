require 'test_helper'

class ActiveScaffold::DataSourcesControllerTest < ActionController::TestCase

	site_administrators.each do |cu|

		test "should get index with #{cu} login" do
			#	active_scaffold pages won't be 100% valid html.
#	Don't know why it won't work here.
#			@controller.class.skip_after_filter :validate_page
Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)
			login_as send(cu)
			get :index
			assert_response :success
		end

	end

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
