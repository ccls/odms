require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'Language',
		:actions => [:new,:create,:edit,:update,:show,:destroy,:index],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_language
	}
	def factory_attributes(options={})
		FactoryGirl.attributes_for(:language,options)
	end

	assert_access_with_login(    :logins => site_administrators )
	assert_no_access_with_login( :logins => non_site_administrators )
	assert_no_access_without_login

	test "language_params should require language" do
		@controller.params=HWIA.new(:no_language => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:language_params).permitted?
		}
	end

	[ :key,:code,:description ].each do |attr|
		test "language_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:language => { attr => 'funky' })
			assert @controller.send(:language_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "language_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:language => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:language_params).permitted?
				assert  @controller.params[:language].has_key?(attr)
				assert !@controller.send(:language_params).has_key?(attr)
			}
		end
	end

end
