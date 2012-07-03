class IcfMasterIdsController < ApplicationController

	before_filter :may_create_icf_master_ids_required,
		:only => [:new,:create]
	before_filter :may_read_icf_master_ids_required,
		:only => [:show,:index]
	before_filter :may_update_icf_master_ids_required,
		:only => [:edit,:update]
	before_filter :may_destroy_icf_master_ids_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@icf_master_ids = IcfMasterId.scoped
	end

#	def update
#		@icf_master_id.update_attributes!(params[:icf_master_id])
#		flash[:notice] = 'Success!'
#		redirect_to icf_master_ids_path
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the icf_master_id"
#		render :action => "edit"
#	end
#
#	def destroy
#		@icf_master_id.destroy
#		redirect_to icf_master_ids_path
#	end

protected

	def valid_id_required
		if( !params[:id].blank? && IcfMasterId.exists?(params[:id]) )
			@icf_master_id = IcfMasterId.find(params[:id])
		else
			access_denied("Valid id required!", icf_master_ids_path)
		end
	end

end
