class VitalStatusesController < ApplicationController

	before_filter :may_create_vital_statuses_required,
		:only => [:new,:create]
	before_filter :may_read_vital_statuses_required,
		:only => [:show,:index]
	before_filter :may_update_vital_statuses_required,
		:only => [:edit,:update]
	before_filter :may_destroy_vital_statuses_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@vital_statuses = VitalStatus.all
	end

	def new
		@vital_status = VitalStatus.new(params[:vital_status])
	end

	def create
		@vital_status = VitalStatus.new(params[:vital_status])
		@vital_status.save!
		flash[:notice] = 'Success!'
		redirect_to @vital_status
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the vital_status"
		render :action => "new"
	end 

	def update
		@vital_status.update_attributes!(params[:vital_status])
		flash[:notice] = 'Success!'
		redirect_to vital_statuses_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the vital_status"
		render :action => "edit"
	end

	def destroy
		@vital_status.destroy
		redirect_to vital_statuses_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && VitalStatus.exists?(params[:id]) )
			@vital_status = VitalStatus.find(params[:id])
		else
			access_denied("Valid id required!", vital_statuses_path)
		end
	end

end
