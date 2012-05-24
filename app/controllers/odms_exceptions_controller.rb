class OdmsExceptionsController < ApplicationController

	before_filter :may_create_odms_exceptions_required,
		:only => [:new,:create]
	before_filter :may_read_odms_exceptions_required,
		:only => [:show,:index]
	before_filter :may_update_odms_exceptions_required,
		:only => [:edit,:update]
	before_filter :may_destroy_odms_exceptions_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@odms_exceptions = OdmsException.all
	end

	def update
		@odms_exception.update_attributes!(params[:odms_exception])
		flash[:notice] = 'Success!'
		redirect_to odms_exceptions_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the odms_exception"
		render :action => "edit"
	end

	def destroy
		@odms_exception.destroy
		redirect_to odms_exceptions_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && OdmsException.exists?(params[:id]) )
			@odms_exception = OdmsException.find(params[:id])
		else
			access_denied("Valid id required!", odms_exceptions_path)
		end
	end

end
