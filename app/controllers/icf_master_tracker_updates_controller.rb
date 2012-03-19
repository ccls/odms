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



	# GET /icf_master_tracker_updates
	# GET /icf_master_tracker_updates.xml
	def index
		@icf_master_tracker_updates = IcfMasterTrackerUpdate.all

#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @icf_master_tracker_updates }
#		end
	end

	# GET /icf_master_tracker_updates/1
	# GET /icf_master_tracker_updates/1.xml
	def show
#		@icf_master_tracker_update = IcfMasterTrackerUpdate.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @icf_master_tracker_update }
#		end
	end

	# GET /icf_master_tracker_updates/new
	# GET /icf_master_tracker_updates/new.xml
	def new
		@icf_master_tracker_update = IcfMasterTrackerUpdate.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @icf_master_tracker_update }
#		end
	end

	# POST /icf_master_tracker_updates
	# POST /icf_master_tracker_updates.xml
	def create
puts "in controller#create"
puts params[:icf_master_tracker_update].inspect
		@icf_master_tracker_update = IcfMasterTrackerUpdate.new(params[:icf_master_tracker_update])

		@icf_master_tracker_update.save!
		flash[:notice] = 'Success!'
		redirect_to @icf_master_tracker_update
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the icf_master_tracker_update"
		render :action => "new"


#		respond_to do |format|
#			if @icf_master_tracker_update.save
#				format.html { redirect_to(@icf_master_tracker_update, :notice => 'IcfMasterTrackerUpdate was successfully created.') }
#				format.xml	{ render :xml => @icf_master_tracker_update, :status => :created, :location => @icf_master_tracker_update }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @icf_master_tracker_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# GET /icf_master_tracker_updates/1/edit
	def edit
#		@icf_master_tracker_update = IcfMasterTrackerUpdate.find(params[:id])
	end

	# PUT /icf_master_tracker_updates/1
	# PUT /icf_master_tracker_updates/1.xml
	def update
puts "in controller#update"
puts params[:icf_master_tracker_update].inspect
	#	@icf_master_tracker_update = IcfMasterTrackerUpdate.find(params[:id])

		@icf_master_tracker_update.update_attributes!(params[:icf_master_tracker_update])
		flash[:notice] = 'Success!'
		redirect_to icf_master_tracker_updates_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the icf_master_tracker_update"
		render :action => "edit"

#		respond_to do |format|
#			if @icf_master_tracker_update.update_attributes(params[:icf_master_tracker_update])
#				format.html { redirect_to(@icf_master_tracker_update, :notice => 'IcfMasterTrackerUpdate was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @icf_master_tracker_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# DELETE /icf_master_tracker_updates/1
	# DELETE /icf_master_tracker_updates/1.xml
	def destroy
#		@icf_master_tracker_update = IcfMasterTrackerUpdate.find(params[:id])
		@icf_master_tracker_update.destroy
		redirect_to(icf_master_tracker_updates_path)

#		respond_to do |format|
#			format.html { redirect_to(icf_master_tracker_updates_url) }
#			format.xml	{ head :ok }
#		end
	end


	def parse
		if !@icf_master_tracker_update.csv_file_file_name.blank? &&
				File.exists?(@icf_master_tracker_update.csv_file.path)
			@results = @icf_master_tracker_update.parse
			f=FasterCSV.open(@icf_master_tracker_update.csv_file.path,'rb',{:headers => true })
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
