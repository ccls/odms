class LiveBirthDataUpdatesController < ApplicationController

	before_filter :may_create_live_birth_data_updates_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_live_birth_data_updates_required,
		:only => [:show,:index]
	before_filter :may_update_live_birth_data_updates_required,
		:only => [:edit,:update]
	before_filter :may_destroy_live_birth_data_updates_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]



	# GET /live_birth_data_updates
	# GET /live_birth_data_updates.xml
	def index
		@live_birth_data_updates = LiveBirthDataUpdate.all

#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @live_birth_data_updates }
#		end
	end

	# GET /live_birth_data_updates/1
	# GET /live_birth_data_updates/1.xml
	def show
#		@live_birth_data_update = LiveBirthDataUpdate.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @live_birth_data_update }
#		end
	end

	# GET /live_birth_data_updates/new
	# GET /live_birth_data_updates/new.xml
	def new
		@live_birth_data_update = LiveBirthDataUpdate.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @live_birth_data_update }
#		end
	end

	# POST /live_birth_data_updates
	# POST /live_birth_data_updates.xml
	def create
		@live_birth_data_update = LiveBirthDataUpdate.new(params[:live_birth_data_update])

		@live_birth_data_update.save!
		flash[:notice] = 'Success!'
		redirect_to @live_birth_data_update
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the live_birth_data_update"
		render :action => "new"


#		respond_to do |format|
#			if @live_birth_data_update.save
#				format.html { redirect_to(@live_birth_data_update, :notice => 'LiveBirthDataUpdate was successfully created.') }
#				format.xml	{ render :xml => @live_birth_data_update, :status => :created, :location => @live_birth_data_update }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @live_birth_data_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# GET /live_birth_data_updates/1/edit
	def edit
#		@live_birth_data_update = LiveBirthDataUpdate.find(params[:id])
	end

	# PUT /live_birth_data_updates/1
	# PUT /live_birth_data_updates/1.xml
	def update
	#	@live_birth_data_update = LiveBirthDataUpdate.find(params[:id])

		@live_birth_data_update.update_attributes!(params[:live_birth_data_update])
		flash[:notice] = 'Success!'
		redirect_to live_birth_data_updates_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the live_birth_data_update"
		render :action => "edit"

#		respond_to do |format|
#			if @live_birth_data_update.update_attributes(params[:live_birth_data_update])
#				format.html { redirect_to(@live_birth_data_update, :notice => 'LiveBirthDataUpdate was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @live_birth_data_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# DELETE /live_birth_data_updates/1
	# DELETE /live_birth_data_updates/1.xml
	def destroy
#		@live_birth_data_update = LiveBirthDataUpdate.find(params[:id])
		@live_birth_data_update.destroy
		redirect_to(live_birth_data_updates_path)

#		respond_to do |format|
#			format.html { redirect_to(live_birth_data_updates_url) }
#			format.xml	{ head :ok }
#		end
	end

	def parse
		if !@live_birth_data_update.csv_file_file_name.blank? &&
				File.exists?(@live_birth_data_update.csv_file.path)
			@results = @live_birth_data_update.to_candidate_controls
			f=FasterCSV.open(@live_birth_data_update.csv_file.path,'rb',{:headers => true })
			@csv_lines = f.readlines
			f.close
		else
			flash[:error] = "Live Birth Data csv file not found."
			redirect_to @live_birth_data_update
		end
	end

protected

	def valid_id_required
		if( !params[:id].blank? && LiveBirthDataUpdate.exists?(params[:id]) )
			@live_birth_data_update = LiveBirthDataUpdate.find(params[:id])
		else
			access_denied("Valid id required!", live_birth_data_updates_path)
		end
	end

end
