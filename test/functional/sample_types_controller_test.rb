require 'test_helper'

class SampleTypesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'SampleType',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample_type
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:sample_type,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	test "sample_type_params should require sample_type" do
		@controller.params=HWIA.new(:no_sample_type => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:sample_type_params).permitted?
		}
	end

	[ :parent_id,:key,:description, :for_new_sample,:t2k_sample_type_id,
			:gegl_sample_type_id ].each do |attr|
		test "sample_type_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:sample_type => { attr => 'funky' })
			assert @controller.send(:sample_type_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "sample_type_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:sample_type => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:sample_type_params).permitted?
				assert  @controller.params[:sample_type].has_key?(attr)
				assert !@controller.send(:sample_type_params).has_key?(attr)
			}
		end
	end

end
