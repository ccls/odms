require 'test_helper'

class HospitalsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Hospital',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_hospital
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:hospital,{
			:organization_id => FactoryGirl.create(:organization).id
		}.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	test "hospital_params should require hospital" do
		@controller.params=HWIA.new(:no_hospital => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:hospital_params).permitted?
		}
	end

	[ :is_active,:has_irb_waiver,:organization_id ].each do |attr|
		test "hospital_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:hospital => { attr => 'funky' })
			assert @controller.send(:hospital_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "hospital_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:hospital => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:hospital_params).permitted?
				assert  @controller.params[:hospital].has_key?(attr)
				assert !@controller.send(:hospital_params).has_key?(attr)
			}
		end
	end

end
