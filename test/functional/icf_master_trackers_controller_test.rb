require 'test_helper'

class IcfMasterTrackersControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IcfMasterTracker',
		:actions => [:index,:show],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_icf_master_tracker
	}
	def factory_attributes(options={})
		Factory.attributes_for(:icf_master_tracker,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login
#	assert_access_with_https
#	assert_no_access_with_http

	site_administrators.each do |cu|

		test "should update with #{cu} login" do
			login_as send(cu)
			icf_master_tracker = Factory(:icf_master_tracker)
			put :update, :id => icf_master_tracker.id
			assert_not_nil flash[:notice]


			assert_redirected_to icf_master_trackers_path
		end
	
	end

	non_site_administrators.each do |cu|

		test "should NOT update with #{cu} login" do
			login_as send(cu)
			icf_master_tracker = Factory(:icf_master_tracker)
			put :update, :id => icf_master_tracker.id
			assert_not_nil flash[:error]
			assert_redirected_to root_path
		end
	
	end

	test "should NOT update without login" do
		icf_master_tracker = Factory(:icf_master_tracker)
		put :update, :id => icf_master_tracker.id
		assert_redirected_to_login
	end

end
