class GuidesController < ApplicationController

	#	Basic CRUD and permissive features defined in simply_authorized
	resourceful

protected

	#	override default from simply_authorized
	def get_new
		@guide = Guide.new(params[:guide])
	end

end
