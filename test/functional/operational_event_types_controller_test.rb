require 'test_helper'

class OperationalEventTypesControllerTest < ActionController::TestCase

	test "should get options without category" do
		get :options
		puts @response.body
	end

	test "should get options with invalid category" do
		get :options, :category => 'IDONOTEXIST'
		puts @response.body
	end

	test "should get options with valid category" do
		category = OperationalEventType.categories.first
		get :options, :category => category
		puts @response.body
	end

end
