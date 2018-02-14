require 'test_helper'

class SampleLocationsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'SampleLocation',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample_location
	}

	def factory_attributes(options={})
		FactoryBot.attributes_for(:sample_location,{
			:organization_id => FactoryBot.create(:organization).id
		}.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	add_strong_parameters_tests( :sample_location,
		[ :is_active,:organization_id ])

end
__END__
