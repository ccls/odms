class EventsController < ApplicationController
	class StudySubjectMismatch < StandardError; end

	layout 'subject'

	before_filter :may_create_events_required,
		:only => [:new,:create]
	before_filter :may_read_events_required,
		:only => [:show,:index]
	before_filter :may_update_events_required,
		:only => [:edit,:update]
	before_filter :may_destroy_events_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:new,:create,:index]

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def show
	end

	def index
#		why not just ...
		@events = @study_subject.operational_events
#			or
#		@events = @study_subject.operational_events(:include => :operational_event_type)
#		doesn't seem to actually get the operational event type.
#		Should try to get the enrollment, project and operational event type
#		I don't think that we do any 'searching' yet
#		This was pre- has_many :through setup
#		@events = OperationalEvent.search(params)
	end

	def new
#	As this is a has_many :through relationship
#		@operational_event = @study_subject.operational_events.new
#	it is no different than
		@operational_event = OperationalEvent.new
	end

	def create
#	As this is a has_many :through relationship
#		@operational_event = @study_subject.operational_events.new(params[:operational_event])
#	it is no different than
		@operational_event = OperationalEvent.new(params[:operational_event])

#	for testing
#raise ActiveRecord::RecordInvalid.new(@operational_event)

#	However, there should be a special check added to ensure that the
#	study_subject from the route is the same study_subject attached
#	to the enrollment.

		enrollment = Enrollment.find(params[:operational_event][:enrollment_id])
		#	This should only happen for all you hackers out there.
		raise StudySubjectMismatch if @study_subject != enrollment.study_subject


		@operational_event.save!
		flash[:notice] = "Operational Event successfully created."
		redirect_to study_subject_events_path(@study_subject)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Operational Event creation failed."
		render :action => 'new'
	rescue EventsController::StudySubjectMismatch
		flash.now[:error] = "Operational Event creation failed. Subject Mismatch."
		render :action => 'new'
	end

	def edit
	end

	def update
		@operational_event.attributes = params[:operational_event]



#	ensure enrollment_id doesn't change study_subjects???



		@operational_event.save!

		redirect_to event_path(@operational_event)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Operational Event update failed."
		render :action => 'edit'
	end

	def destroy
		@operational_event.destroy
		redirect_to study_subject_events_path(
			@operational_event.enrollment.study_subject)
	end

protected

	#	override so can set redirection to something other than root_path
	def may_create_events_required
		( logged_in? and current_user.may_create_events? ) ||
			access_denied("You do not have permission to create events!", 
				study_subject_events_path)
	end

	def valid_id_required
		if !params[:id].blank? and OperationalEvent.exists?(params[:id])
			@operational_event = OperationalEvent.find(params[:id])
			#	study_subject needed in edit form
			@study_subject = @operational_event.enrollment.study_subject
		else
			access_denied("Valid operational_event id required!", study_subjects_path)
		end
	end

end
