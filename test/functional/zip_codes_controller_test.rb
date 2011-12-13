require 'test_helper'

class ZipCodesControllerTest < ActionController::TestCase

	def setup
		#	only validates html pages, not json
		#	don't validate this page.  Should be an easier way, but this works.
		Html::Test::ValidateFilter.any_instance.stubs(:should_validate?).returns(false)
	end

#	zip_codes in html is full html page
#    <h1>ZipCodes#index</h1>
#<p>Find me in app/views/zip_codes/index.html.erb</p>
#<table><tbody>
#<tr>
#<td>NORTHUMBERLAND</td>
#<td>PA</td>
#<td>17857</td>
#<td>Northumberland</td>
#</tr>
#</tbody></table>


#	test "should get zip_codes with no q" do
#		pending	#	TODO
#		get :index
##		puts @response.body
#	end
#
#	test "should get zip_codes with blank q" do
#		pending	#	TODO
#		get :index, :q => ''
##		puts @response.body
#	end
#
#	test "should get zip_codes with partial q" do
#		pending	#	TODO
#		get :index, :q => '178'
##		puts @response.body
#	end
#
#	test "should get zip_codes with full q" do
#		pending	#	TODO
#		get :index, :q => '17857'
##		puts @response.body
#	end

	test "should get zip_codes.json with full q" do
		#	:format MUST be a string and NOT a symbol
		get :index, :q => '17857', :format => 'json'
		expected = %{[{"zip_code":{"county_name":"Northumberland","city":"NORTHUMBERLAND","zip_code":"17857","county_id":2144,"state":"PA"}}]}
		assert_equal expected, @response.body
	end

#	test "should get zip_codes with invalid q" do
#		pending	#	TODO
#		get :index, :q => 'IDONOTEXIST'
##		puts @response.body
#	end

end
