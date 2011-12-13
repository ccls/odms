class OperationalEventTypesController < ApplicationController

#	as is no create, update or destroy, token never used anyway
#	skip_before_filter :verify_authenticity_token

	skip_before_filter :login_required

	def options
		@operational_event_types = OperationalEventType.all(
			:conditions => { :event_category => params[:category] } )
		render :layout => false
	end

end
