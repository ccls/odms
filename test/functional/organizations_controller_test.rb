require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Organization',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_organization
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:organization,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	test "organization_params should require organization" do
		@controller.params=HWIA.new(:no_organization => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:organization_params).permitted?
		}
	end

	[ :key,:name ].each do |attr|
		test "organization_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:organization => { attr => 'funky' })
			assert @controller.send(:organization_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "organization_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:organization => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:organization_params).permitted?
				assert  @controller.params[:organization].has_key?(attr)
				assert !@controller.send(:organization_params).has_key?(attr)
			}
		end
	end

end
