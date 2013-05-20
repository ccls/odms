class ZipCodesController < ApplicationController

#	as is no create, update or destroy, token never used anyway
#	only get index
#	skip_before_filter :verify_authenticity_token

	skip_before_filter :login_required

	def index
#		@zip_codes = ZipCode.joins("LEFT JOIN counties ON zip_codes.county_id = counties.id")
#	agnosticized .... (except perhaps the select line)
		@zip_codes = ZipCode.joins(
			Arel::Nodes::OuterJoin.new(County.arel_table,Arel::Nodes::On.new(
				ZipCode.arel_table[:county_id].eq(County.arel_table[:id]))))
			.select("city, state, zip_code, county_id, counties.name as county_name")
			.order('zip_code ASC')
			.where(ZipCode.arel_table[:zip_code].matches(
				"#{(params[:q]||'').gsub(/\D/,'')[0..4]}%"))
#			.where('zip_code LIKE ?', "#{(params[:q]||'').gsub(/\D/,'')[0..4]}%")
		render :json => @zip_codes.each{|z|z.city = z.city.titleize}
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


