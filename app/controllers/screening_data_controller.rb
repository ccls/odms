class ScreeningDataController < ApplicationController
#
#	before_filter :may_create_screening_data_required,
#		:only => [:new,:create,:parse]
#	before_filter :may_read_screening_data_required,
#		:only => [:show,:index]
#	before_filter :may_update_screening_data_required,
#		:only => [:edit,:update]
#	before_filter :may_destroy_screening_data_required,
#		:only => :destroy
#
#	before_filter :valid_id_required, 
#		:only => [:show,:edit,:update,:destroy,:parse]
#
#	def index
#		@screening_data = ScreeningDatum.scoped
#	end
#
#	def update
#		@screening_datum.update_attributes!(params[:screening_datum])
#		flash[:notice] = 'Success!'
##		redirect_to screening_data_path
##		redirect_to @screening_datum.screening_datum_update
#		redirect_to @screening_datum
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the screening_datum"
#		render :action => "edit"
#	end
#
#	def destroy
#		@screening_datum.destroy
#		redirect_to screening_data_path
#	end
#
#protected
#
#	def valid_id_required
#		if( !params[:id].blank? && ScreeningDatum.exists?(params[:id]) )
#			@screening_datum = ScreeningDatum.find(params[:id])
#		else
#			access_denied("Valid id required!", screening_data_path)
#		end
#	end
#
end
