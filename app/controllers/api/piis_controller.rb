class Api::PiisController < ApiController

	#	MUST skip this filter explicitly on each controller
	#	Skip the calnet authentication
	#	This means no current user and therefore no roles.
	skip_before_filter :login_required

	def index
		@piis = Pii.all
		render :xml => @piis
	end

end
