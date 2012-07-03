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
		@icf_master_trackers = IcfMasterTracker.scoped
#		@icf_master_trackers = IcfMasterTracker.have_changed
	end

	def show
	end

	#	Be advised that this is not an update of the IcfMasterTracker.
	#	This is a trigger to update the associated models of the 
	#	IcfMasterTracker.
	def update
		flash[:notice] = "Attempted update (DEV TODO Nothing actually done yet)"


#	TODO attempt individual update


		redirect_to icf_master_trackers_path
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
