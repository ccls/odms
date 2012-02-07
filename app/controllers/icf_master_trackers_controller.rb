class IcfMasterTrackersController < ApplicationController

	before_filter :may_create_icf_master_trackers_required,
		:only => [:new,:create]
	before_filter :may_read_icf_master_trackers_required,
		:only => [:show,:index]
	before_filter :may_update_icf_master_trackers_required,
		:only => [:edit,:update]
	before_filter :may_destroy_icf_master_trackers_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@icf_master_trackers = IcfMasterTracker.all
	end

protected

	def valid_id_required
		if( !params[:id].blank? && IcfMasterTracker.exists?(params[:id]) )
			@icf_master_tracker = IcfMasterTracker.find(params[:id])
		else
			access_denied("Valid id required!", icf_master_trackers_path )
		end
	end

end
