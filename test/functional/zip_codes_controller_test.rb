require 'test_helper'

class ZipCodesControllerTest < ActionController::TestCase

	def setup
		#	only validates html pages, not json
		#	no more html anyway
		#	These are rendered json, so will be flagged to not 
		#		validate anyway
		#	don't validate this page.  Should be an easier way, but this works.
#		Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)
#		ZipCodesController.skip_after_filter :validate_page
	end

#	test "should get zip_codes with no q" do
#		skip	#	TODO
#		get :index
##		puts @response.body
#	end
#
#	test "should get zip_codes with blank q" do
#		skip	#	TODO
#		get :index, :q => ''
##		puts @response.body
#	end
#
#	test "should get zip_codes with partial q" do
#		skip	#	TODO
#		get :index, :q => '178'
##		puts @response.body
#	end
#
#	test "should get zip_codes with full q" do
#		skip	#	TODO
#		get :index, :q => '17857'
##		puts @response.body
#	end

#--- expected
#+++ actual
#@@ -1 +1 @@
#-[{\"zip_code\":{\"county_name\":\"Northumberland\",\"city\":\"Northumberland\",\"zip_code\":\"17857\",\"county_id\":2144,\"state\":\"PA\"}}]
#+[{\"county_name\":\"Northumberland\",\"city\":\"Northumberland\",\"zip_code\":\"17857\",\"county_id\":2144,\"state\":\"PA\"}]

#		expected = %{[{"zip_code":{"county_name":"Northumberland","city":"Northumberland","zip_code":"17857","county_id":2144,"state":"PA"}}]}
#	rails 3 removes initial key
#		expected = %{[{"county_name":"Northumberland","city":"Northumberland","zip_code":"17857","county_id":2144,"state":"PA"}]}
#	the output is no longer always sorted this way
# expected = %{[{"state":"PA","city":"Northumberland","county_id":2144,"county_name":"Northumberland","zip_code":"17857"}]"}
#		assert_equal expected, @response.body

	test "should get zip_codes.json with 5-digit zip code" do
		#	:format MUST be a string and NOT a symbol
		get :index, :q => '17857', :format => 'json'
		assert_match /"state":"PA"/, @response.body
		assert_match /"city":"Northumberland"/, @response.body
		assert_match /"county_id":2144/, @response.body
		assert_match /"county_name":"Northumberland"/, @response.body
		assert_match /"zip_code":"17857"/, @response.body
	end

	test "should get zip_codes.json with 9-digit zip code" do
		#	:format MUST be a string and NOT a symbol
		get :index, :q => '17857-0123', :format => 'json'
		assert_match /"state":"PA"/, @response.body
		assert_match /"city":"Northumberland"/, @response.body
		assert_match /"county_id":2144/, @response.body
		assert_match /"county_name":"Northumberland"/, @response.body
		assert_match /"zip_code":"17857"/, @response.body
	end

	test "should get zip_codes.json with 9-digit zip code and leading spaces" do
		#	:format MUST be a string and NOT a symbol
		get :index, :q => '   17857-0123', :format => 'json'
		assert_match /"state":"PA"/, @response.body
		assert_match /"city":"Northumberland"/, @response.body
		assert_match /"county_id":2144/, @response.body
		assert_match /"county_name":"Northumberland"/, @response.body
		assert_match /"zip_code":"17857"/, @response.body
	end

	test "should get zip_codes.json with 9-digit zip code and non-numerics" do
		#	:format MUST be a string and NOT a symbol
		get :index, :q => ' EXTRA 1 STUFF 7 HERE 8 AND IS 5 IGNORED 7-0123', :format => 'json'
		assert_match /"state":"PA"/, @response.body
		assert_match /"city":"Northumberland"/, @response.body
		assert_match /"county_id":2144/, @response.body
		assert_match /"county_name":"Northumberland"/, @response.body
		assert_match /"zip_code":"17857"/, @response.body
	end

#	test "should get zip_codes with invalid q" do
#		skip	#	TODO
#		get :index, :q => 'IDONOTEXIST'
##		puts @response.body
#	end

end
