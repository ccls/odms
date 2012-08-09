class EventsController < ApplicationController

	layout 'subject'

	before_filter :may_create_events_required,
		:only => [:new,:create]
	before_filter :may_read_events_required,
		:only => [:show,:index]
	before_filter :may_update_events_required,
		:only => [:edit,:update]
	before_filter :may_destroy_events_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required
#	before_filter :valid_study_subject_id_required,
#		:only => [:new,:create,:index]

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def show
	end

	def index
		@events = @study_subject.operational_events.order(search_order)

		if params[:order] and %w( type ).include?(params[:order].downcase)
			@events = @events
			.joins(:operational_event_type)
			.select('operational_events.*, operational_event_types.event_category AS type')
		end

		if params[:order] and %w( project ).include?(params[:order].downcase)
			@events = @events
			.joins(:project)
			.select('operational_events.*, projects.key AS project')
		end

	end

	def new
		@operational_event = OperationalEvent.new
	end

	def create
		@operational_event = @study_subject.operational_events.new(params[:operational_event])
		@operational_event.save!
		flash[:notice] = "Operational Event successfully created."
		redirect_to study_subject_events_path(@study_subject)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Operational Event creation failed."
		render :action => 'new'
	end

	def edit
	end

	def update
		@operational_event.update_attributes!(params[:operational_event])
		redirect_to study_subject_event_path(@study_subject,@operational_event)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Operational Event update failed."
		render :action => 'edit'
	end

	def destroy
		@operational_event.destroy
		redirect_to study_subject_events_path(@operational_event.study_subject)
	end

protected

	#	override so can set redirection to something other than root_path
	def may_create_events_required
		( logged_in? and current_user.may_create_events? ) ||
			access_denied("You do not have permission to create events!", 
				study_subject_events_path)
	end

	def valid_id_required
		if !params[:id].blank? and @study_subject.operational_events.exists?(params[:id])
			@operational_event = @study_subject.operational_events.find(params[:id])
#		if !params[:id].blank? and OperationalEvent.exists?(params[:id])
#			@operational_event = OperationalEvent.find(params[:id])
#			#	study_subject needed in edit form
#			@study_subject = @operational_event.study_subject
		else
			access_denied("Valid operational_event id required!", study_subjects_path)
		end
	end

	def search_order
		if params[:order] and
				%w( id type project description occurred_at ).include?(
				params[:order].downcase)
			order_string = params[:order]
			dir = case params[:dir].try(:downcase)
				when 'desc' then 'desc'
				else 'asc'
			end
			[order_string,dir].join(' ')
		else
			nil
		end
	end

end
