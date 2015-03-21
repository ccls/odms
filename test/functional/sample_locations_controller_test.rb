require 'test_helper'

class SampleLocationsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'SampleLocation',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample_location
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:sample_location,{
			:organization_id => FactoryGirl.create(:organization).id
		}.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	test "sample_location_params should require sample_location" do
		@controller.params=HWIA.new(:no_sample_location => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:sample_location_params).permitted?
		}
	end

	[ :is_active,:organization_id ].each do |attr|
		test "sample_location_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:sample_location => { attr => 'funky' })
			assert @controller.send(:sample_location_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "sample_location_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:sample_location => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:sample_location_params).permitted?
				assert  @controller.params[:sample_location].has_key?(attr)
				assert !@controller.send(:sample_location_params).has_key?(attr)
			}
		end
	end

end
__END__
