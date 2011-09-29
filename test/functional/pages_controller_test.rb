require 'test_helper'

class PagesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Page',
		:actions => [:new,:create,:edit,:update,:destroy,:index],
		:method_for_create => :factory_create,
		:attributes_for_create => :factory_attributes
	}

	def factory_create(options={})
		Factory(:page,options)
	end
	def factory_attributes(options={})
		Factory.attributes_for(:page,options)
	end

	with_options :actions => [:show] do |show|
		show.assert_access_with_http
		show.assert_access_with_https
		show.assert_access_with_login({
			:logins => [:superuser,:administrator,:editor],
			:skip_show_failure => true })
		show.assert_access_with_login({
			:logins => [:interviewer,:reader,:active_user], 
			:skip_show_failure => true })
		show.assert_access_without_login
	end

	assert_no_access_with_login({ 
		:logins => [:interviewer,:reader,:active_user] })
	assert_no_access_without_login
	assert_no_access_with_http 

	%w( superuser administrator editor ).each do |cu|
	#
	#		index/new/create/edit/update/destroy 
	#			should only be visible to admins for editing
	#	

		test "should get all with pages with #{cu} login" do
			login_as send(cu)
			get :all
			assert_template 'all'
			assert_response :success
			assert_equal Page.count, assigns(:pages).length
		end

		test "should get index with pages with #{cu} login" do
			3.times{ factory_create }
			login_as send(cu)
			get :index
			assert_template 'index'
			assert_response :success
			assert_not_nil assigns(:pages)
			assigns(:pages).each { |page| assert_nil page.parent }
#	this isn't always true, depending the apps fixtures/pages.yml
#			assert Page.count != assigns(:pages).length
		end

		test "should get index with blank parent with #{cu} login" do
			3.times{ factory_create }
			login_as send(cu)
			get :index, :parent_id => ''
			assert_template 'index'
			assert_response :success
			assert_not_nil assigns(:pages)
			assigns(:pages).each { |page| assert_nil page.parent }
		end

		test "should get index with subpages with #{cu} login" do
			parent = factory_create
			3.times{ factory_create(:parent_id => parent.id) }
			login_as send(cu)
			get :index, :parent_id => parent.id
			assert_template 'index'
			assert_response :success
			assert_not_nil assigns(:pages)
			assigns(:pages).each do |page|
				assert_equal page.parent_id, parent.id
			end
		end

		test "should create page with parent with #{cu} login" do
			parent = factory_create
			login_as send(cu)
			assert_difference('Page.count') do
				post :create, :page => factory_attributes(
					:parent_id => parent.id)
			end
			assert_equal parent, assigns(:page).parent
			assert_redirected_to page_path(assigns(:page))
		end

		#	I don't think that this is pertinant anymore
		test "should get index with both help and non-help pages with #{cu} login" do
			#	test css menus
			login_as send(cu)
			nonhelp_page = factory_create(:path => "/hello" )
			help_page = factory_create(:path => "/help/test" )
			get :index
			assert_response :success
			assert_template 'index'
		end

	#	action: order

		test "should order pages with #{cu} login" do
			login_as send(cu)
	#		pages = 3.times.collect{|i| factory_create }
	#	3.times.collect doesn't work on 
	#> ruby --version
	#ruby 1.8.6 (2008-08-11 patchlevel 287) [universal-darwin9.0]
			pages = []
			3.times{ pages.push(factory_create) }
			before_page_ids = Page.all.collect(&:id)
			post :order, :pages => before_page_ids.reverse
			after_page_ids = Page.all.collect(&:id)
			assert_equal after_page_ids, before_page_ids.reverse
			assert_redirected_to pages_path
		end

		test "should NOT order pages without pages with #{cu} login" do
			login_as send(cu)
			post :order
			assert_not_nil flash[:error]
			assert_redirected_to pages_path
		end

		test "should order sub pages with #{cu} login" do
			login_as send(cu)
			parent = factory_create
			pages = []
			3.times{ pages.push(factory_create(:parent_id => parent.id)) }
			assert_equal [1,2,3], pages.collect(&:position)
			before_page_ids = parent.reload.children.collect(&:id)
			post :order,:parent_id => parent.id, :pages => before_page_ids.reverse
			after_page_ids = parent.reload.children.collect(&:id)
			assert_equal after_page_ids, before_page_ids.reverse
			assert_redirected_to pages_path(:parent_id => parent.id)
		end

	end

	%w( interviewer reader active_user ).each do |cu|

		test "should NOT order pages with #{cu} login" do
			login_as send(cu)
			pages = []
			3.times{ pages.push(factory_create) }
			before_page_ids = Page.all.collect(&:id)
			post :order, :pages => before_page_ids.reverse
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end

	end

	test "should NOT order pages without login" do
		pages = []
		3.times{ pages.push(factory_create) }
		before_page_ids = Page.all.collect(&:id)
		post :order, :pages => before_page_ids.reverse
		assert_redirected_to_login
	end

#
#	/pages/:id should be visible to anyone ?
#
#	as the pages controller uses the gateway filter, not being logged in currently
#	requires the addition of the line ...
#		CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(false)
#

	test "should NOT show page with invalid id" do
		get :show, :id => 0
		assert_not_nil flash[:error]
		assert_template 'show'
		assert_response :success
	end

	test "should NOT show page without matching path" do
		get :show, :path => "/i/do/not/exist".split('/').delete_if{|x|x.blank?}
		assert_not_nil flash[:error]
		assert_template 'show'
		assert_response :success
	end

	test "should show page by path" do
		page = factory_create
		get :show, :path => page.path.split('/').delete_if{|x|x.blank?}
		assert_equal assigns(:page), page
		assert_template 'show'
		assert_response :success
		assert_select 'title', page.title
	end

	test "should show page by path with slashes" do
		page = factory_create(:path => "/help/blogs")
		get :show, :path => page.path.split('/').delete_if{|x|x.blank?}
		assert_equal assigns(:page), page
		assert_template 'show'
		assert_response :success
		assert_select 'title', page.title
	end

	test "should show HOME page without HPP" do
		page = Page.by_path('/')
		get :show, :id => page.id
		assert_nil assigns(:hpp)
		assert_template 'show'
		assert_response :success
		assert_select 'title', page.title
	end

	test "should get translate via js without login" do
		@request.accept = "text/javascript"
		get :translate
		assert_response :success
		assert_match /jQuery/, @response.body
	end

	test "should get each page in fixtures in each locale" do
		puts
		Page.all.each do |page|
			[ nil,'en','es' ].each do |locale|
				puts "- Showing page id #{page.id} with locale #{locale}"
				session[:locale] = locale
				get :show, :id => page.id
				assert_response :success
				assert_template 'show'
			end
		end
	end

end
