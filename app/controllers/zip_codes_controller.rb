class ZipCodesController < ApplicationController

#	as is no create, update or destroy, token never used anyway
#	skip_before_filter :verify_authenticity_token

	skip_before_filter :login_required

	def index
		@zip_codes = ZipCode.find(:all,
			:select => "city, state, zip_code, county_id, counties.name as county_name",
			:joins => "LEFT JOIN counties ON zip_codes.county_id = counties.id",
			:conditions => [ 'zip_code LIKE ?', "#{params[:q]}%" ])
#		respond_to do |format|
#			format.html	#	for testing only
#			format.json { render :json => @zip_codes }
#		end
#
#
		render :json => @zip_codes
	end

end

__END__

#	in rails 3, this no longer includes the initial key, which seems odd

setting will put it back, but I've modified the javascript already
so may not be needed

could put this in config/environment.rb
ActiveRecord::Base.include_root_in_json = true

or something like this in config block in config/application.rb
config.active_record.include_root_in_json = false



  1) Failure:
test_should_get_zip_codes.json_with_full_q(ZipCodesControllerTest) [test/functional/zip_codes_controller_test.rb:49]:
<"[{\"zip_code\":{\"county_name\":\"Northumberland\",\"city\":\"NORTHUMBERLAND\",\"zip_code\":\"17857\",\"county_id\":2144,\"state\":\"PA\"}}]"> expected but was
<"[{\"county_name\":\"Northumberland\",\"city\":\"NORTHUMBERLAND\",\"zip_code\":\"17857\",\"county_id\":2144,\"state\":\"PA\"}]">.


