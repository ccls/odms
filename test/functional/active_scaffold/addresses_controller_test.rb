require 'test_helper'

class ActiveScaffold::AddressesControllerTest < ActionController::TestCase

	site_administrators.each do |cu|

		#	get collection
#		%w( index edit_associated new_existing list render_field show_search new ).each do |action|
		%w( index list show_search ).each do |action|
	
			test "should get #{action} with #{cu} login" do
				#	active_scaffold pages won't be 100% valid html.
				@controller.class.skip_after_filter :validate_page
				login_as send(cu)
				get action
				assert_response :success
			end
	
		end
	
		#	post collection
		%w( add_existing create ).each do |action|
	
#			test "should post #{action} with #{cu} login" do
#				#	active_scaffold pages won't be 100% valid html.
#				@controller.class.skip_after_filter :validate_page
#				login_as send(cu)
#				post action
#				assert_response :success
#			end
	
		end
	
		#	get member
#		%w( edit edit_associated nested row render_field delete add_association show ).each do |action|
		%w( edit nested row show ).each do |action|
	
			test "should get #{action} member with #{cu} login" do
				#	active_scaffold pages won't be 100% valid html.
				@controller.class.skip_after_filter :validate_page
				login_as send(cu)
				address = Factory(:address)
				get action, :id => address.id
				assert_response :success
			end
	
		end
	
		#	post member
		%w( update_column ).each do |action|
	
			test "should post #{action} member with #{cu} login" do
				#	active_scaffold pages won't be 100% valid html.
				@controller.class.skip_after_filter :validate_page
				login_as send(cu)
				address = Factory(:address)
#				post action, :id => address.id, :address => Factory.attributes_for(:address)
#				assert_response :success
			end
	
		end
	
		#	put member
		%w( update ).each do |action|
	
			test "should put #{action} member with #{cu} login" do
				#	active_scaffold pages won't be 100% valid html.
				@controller.class.skip_after_filter :validate_page
				login_as send(cu)
				address = Factory(:address)
#				put action, :id => address.id, :address => Factory.attributes_for(:address)
#				assert_response :success
			end
	
		end
	
		#	delete member
		%w( destroy destroy_existing ).each do |action|
	
#	no route
#			test "should delete #{action} member with #{cu} login" do
#				#	active_scaffold pages won't be 100% valid html.
#				@controller.class.skip_after_filter :validate_page
#				login_as send(cu)
#				address = Factory(:address)
#				delete action, :id => address.id
#				assert_response :success
#			end
	
		end

	end

#
#	I am more interested that the following will NOT happen 
#	rather than the prior will.  Below are all of the
#	ActiveScaffold and RESTful routes, none of which should
#	work for anyone other that administrators.
#

	non_site_administrators.each do |cu|

		#	get collection
		%w( index edit_associated new_existing list render_field show_search new ).each do |action|
	
			test "should NOT get #{action} with #{cu} login" do
				login_as send(cu)
				get action
				assert_redirected_to root_path
			end
	
		end
	
		#	post collection
		%w( add_existing create ).each do |action|
	
			test "should NOT post #{action} with #{cu} login" do
				login_as send(cu)
				post action
				assert_redirected_to root_path
			end
	
		end
	
		#	get member
		%w( edit edit_associated nested row render_field delete add_association show ).each do |action|
	
			test "should NOT get #{action} member with #{cu} login" do
				login_as send(cu)
				address = Factory(:address)
				get action, :id => address.id
				assert_redirected_to root_path
			end
	
		end
	
		#	post member
		%w( update_column ).each do |action|
	
			test "should NOT post #{action} member with #{cu} login" do
				login_as send(cu)
				address = Factory(:address)
				post action, :id => address.id, :address => Factory.attributes_for(:address)
				assert_redirected_to root_path
			end
	
		end
	
		#	put member
		%w( update ).each do |action|
	
			test "should NOT put #{action} member with #{cu} login" do
				login_as send(cu)
				address = Factory(:address)
				put action, :id => address.id, :address => Factory.attributes_for(:address)
				assert_redirected_to root_path
			end
	
		end
	
		#	delete member
		%w( destroy destroy_existing ).each do |action|
	
			test "should NOT delete #{action} member with #{cu} login" do
				login_as send(cu)
				address = Factory(:address)
				delete action, :id => address.id
				assert_redirected_to root_path
			end
	
		end

	end

	#	get collection
	%w( index edit_associated new_existing list render_field show_search new ).each do |action|

		test "should NOT get #{action} without login" do
			get action
			assert_redirected_to_login
		end

	end

	#	post collection
	%w( add_existing create ).each do |action|

		test "should NOT post #{action} without login" do
			post action
			assert_redirected_to_login
		end

	end

	#	get member
	%w( edit edit_associated nested row render_field delete add_association show ).each do |action|

		test "should NOT get #{action} member without login" do
			address = Factory(:address)
			get action, :id => address.id
			assert_redirected_to_login
		end

	end

	#	post member
	%w( update_column ).each do |action|

		test "should NOT put #{action} member without login" do
			address = Factory(:address)
			post action, :id => address.id, :address => Factory.attributes_for(:address)
			assert_redirected_to_login
		end

	end

	#	put member
	%w( update ).each do |action|

		test "should NOT put #{action} member without login" do
			address = Factory(:address)
			put action, :id => address.id, :address => Factory.attributes_for(:address)
			assert_redirected_to_login
		end

	end

	#	delete member
	%w( destroy destroy_existing ).each do |action|

		test "should NOT delete #{action} member without login" do
			address = Factory(:address)
			delete action, :id => address.id
			assert_redirected_to_login
		end

	end

end
