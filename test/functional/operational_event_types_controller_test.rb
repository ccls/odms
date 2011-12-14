require 'test_helper'

class OperationalEventTypesControllerTest < ActionController::TestCase

	def setup
		#	only validates html pages, not json
		#	These will be partials, and even though requested
		#		via javascript/ajax, they are still treated as html
		#		and as such will attempt validation, so ...
		#	don't validate this page.  Should be an easier way, but this works.
#		Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)

		OperationalEventTypesController.skip_after_filter :validate_page
	end

	test "should get options without category" do
		get :options, :format => 'js'
#		puts @response.body
#	this will probably change as all will have categories
#	<option value="##">:other event - please specify</option>
#		assert_select 'option'
	end

	test "should get options with invalid category" do
		get :options, :category => 'IDONOTEXIST', :format => 'js'
		assert @response.body.blank?
	end

	test "should get options with valid category" do
		category = OperationalEventType.categories.first
		get :options, :category => category, :format => 'js'
		assert_select 'option'
#		puts @response.body
#	<option value="##">ascertainment:A new RAF was sent for an existing patient</option>
#	<option value="##">ascertainment:New subject created by CCLS</option>
	end

end
