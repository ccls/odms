require 'csv'
class IcfMasterTrackerUpdatesController < ApplicationController

	before_filter :may_create_icf_master_tracker_updates_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_icf_master_tracker_updates_required,
		:only => [:show,:index]
	before_filter :may_update_icf_master_tracker_updates_required,
		:only => [:edit,:update]
	before_filter :may_destroy_icf_master_tracker_updates_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]

	def index
		@icf_master_tracker_updates = IcfMasterTrackerUpdate.scoped
	end

	def show
	end

	def new
		@icf_master_tracker_update = IcfMasterTrackerUpdate.new
	end

	def create
		@icf_master_tracker_update = IcfMasterTrackerUpdate.new(
			params[:icf_master_tracker_update])
		@icf_master_tracker_update.save!
		flash[:notice] = 'Success!'
		redirect_to @icf_master_tracker_update
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the icf_master_tracker_update"
		render :action => "new"
	end

	def edit
	end

	def update
		@icf_master_tracker_update.update_attributes!(params[:icf_master_tracker_update])
		flash[:notice] = 'Success!'
		redirect_to icf_master_tracker_updates_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the icf_master_tracker_update"
		render :action => "edit"
	end

	def destroy
		@icf_master_tracker_update.destroy
		redirect_to(icf_master_tracker_updates_path)
	end

	def parse
		if !@icf_master_tracker_update.csv_file_file_name.blank? &&
				File.exists?(@icf_master_tracker_update.csv_file.path)
			@results = @icf_master_tracker_update.parse
			f=CSV.open(@icf_master_tracker_update.csv_file.path,'rb',{:headers => true })
			@csv_lines = f.readlines
			f.close
		else
			flash[:error] = "Icf Master Tracker csv file not found."
			redirect_to @icf_master_tracker_update
		end
	end

protected

	def valid_id_required
		if( !params[:id].blank? && IcfMasterTrackerUpdate.exists?(params[:id]) )
			@icf_master_tracker_update = IcfMasterTrackerUpdate.find(params[:id])
		else
			access_denied("Valid id required!", icf_master_tracker_updates_path)
		end
	end

end
