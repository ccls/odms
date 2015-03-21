require 'test_helper'

class IneligibleReasonsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'IneligibleReason',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_ineligible_reason
	}
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:ineligible_reason,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	test "ineligible_reason_params should require ineligible_reason" do
		@controller.params=HWIA.new(:no_ineligible_reason => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:ineligible_reason_params).permitted?
		}
	end

	[ :key,:description ].each do |attr|
		test "ineligible_reason_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:ineligible_reason => { attr => 'funky' })
			assert @controller.send(:ineligible_reason_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "ineligible_reason_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:ineligible_reason => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:ineligible_reason_params).permitted?
				assert  @controller.params[:ineligible_reason].has_key?(attr)
				assert !@controller.send(:ineligible_reason_params).has_key?(attr)
			}
		end
	end

end
