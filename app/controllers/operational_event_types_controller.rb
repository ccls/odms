class OperationalEventTypesController < ApplicationController

#	as is no create, update or destroy, token never used anyway
#	skip_before_filter :verify_authenticity_token

	skip_before_filter :login_required, :only => :options

	def options
		@operational_event_types = OperationalEventType.where(
			:event_category => params[:category] )
		render :layout => false
	end


	before_filter :may_create_operational_event_types_required,
		:only => [:new,:create]
	before_filter :may_read_operational_event_types_required,
		:only => [:show,:index]
	before_filter :may_update_operational_event_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_operational_event_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@operational_event_types = OperationalEventType.scoped
	end

	def new
		@operational_event_type = OperationalEventType.new(params[:operational_event_type])
	end

	def create
		@operational_event_type = OperationalEventType.new(params[:operational_event_type])
		@operational_event_type.save!
		flash[:notice] = 'Success!'
		redirect_to @operational_event_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the operational_event_type"
		render :action => "new"
	end 

	def update
		@operational_event_type.update_attributes!(params[:operational_event_type])
		flash[:notice] = 'Success!'
		redirect_to operational_event_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the operational_event_type"
		render :action => "edit"
	end

	def destroy
		@operational_event_type.destroy
		redirect_to operational_event_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && OperationalEventType.exists?(params[:id]) )
			@operational_event_type = OperationalEventType.find(params[:id])
		else
			access_denied("Valid id required!", operational_event_types_path)
		end
	end

end
