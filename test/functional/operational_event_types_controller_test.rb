require 'test_helper'

class OperationalEventTypesControllerTest < ActionController::TestCase

	def skip_validation
		#	only validates html pages, not json
		#	These will be partials, and even though requested
		#		via javascript/ajax, they are still treated as html
		#		and as such will attempt validation, so ...
		#	don't validate this page.  Should be an easier way, but this works.
#		Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)

		OperationalEventTypesController.skip_after_filter :validate_page
	end

	test "should get options without category" do
skip_validation
		get :options, :format => 'js'
#		puts @response.body
#	this will probably change as all will have categories
#	<option value="##">:other event - please specify</option>
#		assert_select 'option'
	end

	test "should get options with invalid category" do
skip_validation
		get :options, :category => 'IDONOTEXIST', :format => 'js'
		assert @response.body.blank?
	end

	test "should get options with valid category" do
skip_validation
		category = OperationalEventType.categories.first
		get :options, :category => category, :format => 'js'
		assert_select 'option'
#		puts @response.body
#	<option value="##">ascertainment:A new RAF was sent for an existing patient</option>
#	<option value="##">ascertainment:New subject created by CCLS</option>
	end


	ASSERT_ACCESS_OPTIONS = {
		:model => 'OperationalEventType',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_operational_event_type
	}

	def factory_attributes(options={})
		FactoryGirl.attributes_for(:operational_event_type,options)
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

	test "operational_event_type_params should require operational_event_type" do
		@controller.params=HWIA.new(:no_operational_event_type => { :foo => 'bar' })
		assert_raises( ActionController::ParameterMissing ){
			assert !@controller.send(:operational_event_type_params).permitted?
		}
	end

	[ :key,:description,:event_category ].each do |attr|
		test "operational_event_type_params should permit #{attr} subkey" do
			@controller.params=HWIA.new(:operational_event_type => { attr => 'funky' })
			assert @controller.send(:operational_event_type_params).permitted?
		end
	end

	%w( id ).each do |attr|
		test "operational_event_type_params should NOT permit #{attr} subkey" do
			@controller.params=HWIA.new(:operational_event_type => { attr => 'funky' })
			assert_raises( ActionController::UnpermittedParameters ){
				assert !@controller.send(:operational_event_type_params).permitted?
				assert  @controller.params[:operational_event_type].has_key?(attr)
				assert !@controller.send(:operational_event_type_params).has_key?(attr)
			}
		end
	end

end
