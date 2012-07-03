class TracingStatusesController < ApplicationController

	before_filter :may_create_tracing_statuses_required,
		:only => [:new,:create]
	before_filter :may_read_tracing_statuses_required,
		:only => [:show,:index]
	before_filter :may_update_tracing_statuses_required,
		:only => [:edit,:update]
	before_filter :may_destroy_tracing_statuses_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@tracing_statuses = TracingStatus.scoped
	end

	def new
		@tracing_status = TracingStatus.new(params[:tracing_status])
	end

	def create
		@tracing_status = TracingStatus.new(params[:tracing_status])
		@tracing_status.save!
		flash[:notice] = 'Success!'
		redirect_to @tracing_status
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the tracing_status"
		render :action => "new"
	end 

	def update
		@tracing_status.update_attributes!(params[:tracing_status])
		flash[:notice] = 'Success!'
		redirect_to tracing_statuses_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the tracing_status"
		render :action => "edit"
	end

	def destroy
		@tracing_status.destroy
		redirect_to tracing_statuses_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && TracingStatus.exists?(params[:id]) )
			@tracing_status = TracingStatus.find(params[:id])
		else
			access_denied("Valid id required!", tracing_statuses_path)
		end
	end

end
