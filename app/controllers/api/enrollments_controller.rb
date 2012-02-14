class Api::EnrollmentsController < ApiController

	#	MUST skip this filter explicitly on each controller
	#	Skip the calnet authentication
	#	This means no current user and therefore no roles.
	skip_before_filter :login_required

	def index
		@enrollments = Enrollment.all
		render :xml => @enrollments
	end

end
