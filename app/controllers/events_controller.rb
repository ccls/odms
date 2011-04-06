class EventsController < ApplicationController

	permissive

	before_filter :valid_hx_subject_id_required,
		:only => [:new,:create,:index]

	def index
		hx_enrollment = @subject.hx_enrollment
		@events = if hx_enrollment
			hx_enrollment.operational_events.search(params)
		else
			[]
		end
	end

end
