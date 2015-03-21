require 'test_helper'

class RacesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Race',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_race
	}
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:race,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	test "race_params should require race" do
		@controller.params=HWIA.new(:no_race => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:race_params).permitted?
		}
	end

	[ :key,:code,:description ].each do |attr|
		test "race_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:race => { attr => 'funky' })
			assert @controller.send(:race_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "race_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:race => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:race_params).permitted?
				assert  @controller.params[:race].has_key?(attr)
				assert !@controller.send(:race_params).has_key?(attr)
			}
		end
	end

end
