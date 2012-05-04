class BirthDataUpdatesController < ApplicationController

	before_filter :may_create_birth_data_updates_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_birth_data_updates_required,
		:only => [:show,:index]
	before_filter :may_update_birth_data_updates_required,
		:only => [:edit,:update]
	before_filter :may_destroy_birth_data_updates_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]



	# GET /birth_data_updates
	# GET /birth_data_updates.xml
	def index
		@birth_data_updates = BirthDataUpdate.all

#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @birth_data_updates }
#		end
	end

	# GET /birth_data_updates/1
	# GET /birth_data_updates/1.xml
	def show
#		@birth_data_update = BirthDataUpdate.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @birth_data_update }
#		end
	end

	# GET /birth_data_updates/new
	# GET /birth_data_updates/new.xml
	def new
		@birth_data_update = BirthDataUpdate.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @birth_data_update }
#		end
	end

	# POST /birth_data_updates
	# POST /birth_data_updates.xml
	def create
		@birth_data_update = BirthDataUpdate.new(params[:birth_data_update])

		@birth_data_update.save!
		flash[:notice] = 'Success!'
		redirect_to @birth_data_update
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the birth_data_update"
		render :action => "new"


#		respond_to do |format|
#			if @birth_data_update.save
#				format.html { redirect_to(@birth_data_update, :notice => 'BirthDataUpdate was successfully created.') }
#				format.xml	{ render :xml => @birth_data_update, :status => :created, :location => @birth_data_update }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @birth_data_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# GET /birth_data_updates/1/edit
	def edit
#		@birth_data_update = BirthDataUpdate.find(params[:id])
	end

	# PUT /birth_data_updates/1
	# PUT /birth_data_updates/1.xml
	def update
	#	@birth_data_update = BirthDataUpdate.find(params[:id])

		@birth_data_update.update_attributes!(params[:birth_data_update])
		flash[:notice] = 'Success!'
		redirect_to birth_data_updates_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the birth_data_update"
		render :action => "edit"

#		respond_to do |format|
#			if @birth_data_update.update_attributes(params[:birth_data_update])
#				format.html { redirect_to(@birth_data_update, :notice => 'BirthDataUpdate was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @birth_data_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# DELETE /birth_data_updates/1
	# DELETE /birth_data_updates/1.xml
	def destroy
#		@birth_data_update = BirthDataUpdate.find(params[:id])
		@birth_data_update.destroy
		redirect_to(birth_data_updates_path)

#		respond_to do |format|
#			format.html { redirect_to(birth_data_updates_url) }
#			format.xml	{ head :ok }
#		end
	end

	def parse
		if !@birth_data_update.csv_file_file_name.blank? &&
				File.exists?(@birth_data_update.csv_file.path)
			@results = @birth_data_update.to_candidate_controls
			f=FasterCSV.open(@birth_data_update.csv_file.path,'rb',{:headers => true })
			@csv_lines = f.readlines
			f.close
		else
			flash[:error] = "Birth Data csv file not found."
			redirect_to @birth_data_update
		end
	end

protected

	def valid_id_required
		if( !params[:id].blank? && BirthDataUpdate.exists?(params[:id]) )
			@birth_data_update = BirthDataUpdate.find(params[:id])
		else
			access_denied("Valid id required!", birth_data_updates_path)
		end
	end

end
