class Api::AddressesController < ApiController
#
#	#	MUST skip this filter explicitly on each controller
#	#	Skip the calnet authentication
#	#	This means no current user and therefore no roles.
#	skip_before_filter :login_required
#
#	def index
#		@addresses = Address.all
#		render :xml => @addresses
#	end
#
end
