class HomeExposuresController < ApplicationController

#	This is the root path.  There should be nothing
#	here to block any user.  No filters!
	skip_before_filter :login_required

	def show
		@page = Page.by_path("/")
	end

end
