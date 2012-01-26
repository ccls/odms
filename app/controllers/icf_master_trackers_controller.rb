class IcfMasterTrackersController < ApplicationController

	before_filter :may_create_icf_master_trackers_required,
		:only => [:new,:create]	#,:parse]
	before_filter :may_read_icf_master_trackers_required,
		:only => [:show,:index]
	before_filter :may_update_icf_master_trackers_required,
		:only => [:edit,:update]
	before_filter :may_destroy_icf_master_trackers_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]	#,:parse]



	# GET /icf_master_trackers
	# GET /icf_master_trackers.xml
	def index
		@icf_master_trackers = IcfMasterTracker.all

#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @icf_master_trackers }
#		end
	end

	# GET /icf_master_trackers/1
	# GET /icf_master_trackers/1.xml
	def show
#		@icf_master_tracker = IcfMasterTracker.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @icf_master_tracker }
#		end
	end

	# GET /icf_master_trackers/new
	# GET /icf_master_trackers/new.xml
	def new
		@icf_master_tracker = IcfMasterTracker.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @icf_master_tracker }
#		end
	end

	# POST /icf_master_trackers
	# POST /icf_master_trackers.xml
	def create
		@icf_master_tracker = IcfMasterTracker.new(params[:icf_master_tracker])

		@icf_master_tracker.save!
		flash[:notice] = 'Success!'
		redirect_to @icf_master_tracker
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the icf_master_tracker"
		render :action => "new"


#		respond_to do |format|
#			if @icf_master_tracker.save
#				format.html { redirect_to(@icf_master_tracker, :notice => 'IcfMasterTracker was successfully created.') }
#				format.xml	{ render :xml => @icf_master_tracker, :status => :created, :location => @icf_master_tracker }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @icf_master_tracker.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# GET /icf_master_trackers/1/edit
	def edit
#		@icf_master_tracker = IcfMasterTracker.find(params[:id])
	end

	# PUT /icf_master_trackers/1
	# PUT /icf_master_trackers/1.xml
	def update
	#	@icf_master_tracker = IcfMasterTracker.find(params[:id])

		@icf_master_tracker.update_attributes!(params[:icf_master_tracker])
		flash[:notice] = 'Success!'
		redirect_to icf_master_trackers_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the icf_master_tracker"
		render :action => "edit"

#		respond_to do |format|
#			if @icf_master_tracker.update_attributes(params[:icf_master_tracker])
#				format.html { redirect_to(@icf_master_tracker, :notice => 'IcfMasterTracker was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @icf_master_tracker.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# DELETE /icf_master_trackers/1
	# DELETE /icf_master_trackers/1.xml
	def destroy
#		@icf_master_tracker = IcfMasterTracker.find(params[:id])
		@icf_master_tracker.destroy
		redirect_to(icf_master_trackers_path)

#		respond_to do |format|
#			format.html { redirect_to(icf_master_trackers_url) }
#			format.xml	{ head :ok }
#		end
	end


#	def parse
#		@results = @icf_master_tracker.to_candidate_controls
#		f=FasterCSV.open(@icf_master_tracker.csv_file.path,'rb',{:headers => true })
#		@csv_lines = f.readlines
#		f.close
#	end

protected

	def valid_id_required
		if( !params[:id].blank? && IcfMasterTracker.exists?(params[:id]) )
			@icf_master_tracker = IcfMasterTracker.find(params[:id])
		else
			access_denied("Valid id required!", icf_master_trackers_path)
		end
	end

end
