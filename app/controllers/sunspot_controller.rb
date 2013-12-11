class SunspotController < ApplicationController

	before_filter :may_read_required

	include ActiveRecordSunspotter::SearchSunspotFor

end
