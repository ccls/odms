require 'test_helper'

class GuidesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Guide',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_guide
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:guide,options)
	end

	assert_access_with_login({    :logins => site_editors })
	assert_no_access_with_login({ :logins => non_site_editors })
	assert_no_access_without_login

	test "guide_params should require guide" do
		@controller.params=HWIA.new(:no_guide => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:guide_params).permitted?
		}
	end

	[ :controller,:action,:body ].each do |attr|
		test "guide_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:guide => { attr => 'funky' })
			assert @controller.send(:guide_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "guide_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:guide => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:guide_params).permitted?
				assert  @controller.params[:guide].has_key?(attr)
				assert !@controller.send(:guide_params).has_key?(attr)
			}
		end
	end

end
