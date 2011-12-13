require 'test_helper'

class ZipCodesControllerTest < ActionController::TestCase

	test "should get zip_codes with no q" do
		pending	#	TODO
		get :index
		puts @response.body
	end

	test "should get zip_codes with blank q" do
		pending	#	TODO
		get :index, :q => ''
		puts @response.body
	end

	test "should get zip_codes with partial q" do
		pending	#	TODO
		get :index, :q => '178'
		puts @response.body
	end

	test "should get zip_codes with full q" do
		pending	#	TODO
		get :index, :q => '17857'
		puts @response.body
	end

	test "should get zip_codes with invalid q" do
		pending	#	TODO
		get :index, :q => 'IDONOTEXIST'
		puts @response.body
	end

end
