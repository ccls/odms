class IcfMasterIdsController < ApplicationController

	before_filter :may_read_icf_master_ids_required,
		:only => [:show,:index]

	before_filter :valid_id_required, 
		:only => [:show,:destroy]

	def index
		@icf_master_ids = IcfMasterId.all
	end

protected

	def valid_id_required
		if( !params[:id].blank? && IcfMasterId.exists?(params[:id]) )
			@icf_master_id = IcfMasterId.find(params[:id])
		else
			access_denied("Valid id required!", icf_master_ids_path)
		end
	end

end
