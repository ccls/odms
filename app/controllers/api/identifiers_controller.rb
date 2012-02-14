class Api::IdentifiersController < ApiController

	#	MUST skip this filter explicitly on each controller
	#	Skip the calnet authentication
	#	This means no current user and therefore no roles.
	skip_before_filter :login_required

	def index
		@identifiers = Identifier.all
		render :xml => @identifiers
	end

end
