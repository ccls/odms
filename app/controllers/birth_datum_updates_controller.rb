class BirthDatumUpdatesController < ApplicationController

	before_filter :may_create_birth_datum_updates_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_birth_datum_updates_required,
		:only => [:show,:index]
	before_filter :may_update_birth_datum_updates_required,
		:only => [:edit,:update]
	before_filter :may_destroy_birth_datum_updates_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]



	# GET /birth_datum_updates
	# GET /birth_datum_updates.xml
	def index
		@birth_datum_updates = BirthDatumUpdate.all

#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @birth_datum_updates }
#		end
	end

	# GET /birth_datum_updates/1
	# GET /birth_datum_updates/1.xml
	def show
#		@birth_datum_update = BirthDatumUpdate.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @birth_datum_update }
#		end
	end

	# GET /birth_datum_updates/new
	# GET /birth_datum_updates/new.xml
	def new
		@birth_datum_update = BirthDatumUpdate.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @birth_datum_update }
#		end
	end

	# POST /birth_datum_updates
	# POST /birth_datum_updates.xml
	def create
		@birth_datum_update = BirthDatumUpdate.new(params[:birth_datum_update])

		@birth_datum_update.save!
		flash[:notice] = 'Success!'
		redirect_to @birth_datum_update
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the birth_datum_update"
		render :action => "new"


#		respond_to do |format|
#			if @birth_datum_update.save
#				format.html { redirect_to(@birth_datum_update, :notice => 'BirthDatumUpdate was successfully created.') }
#				format.xml	{ render :xml => @birth_datum_update, :status => :created, :location => @birth_datum_update }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @birth_datum_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# GET /birth_datum_updates/1/edit
	def edit
#		@birth_datum_update = BirthDatumUpdate.find(params[:id])
	end

	# PUT /birth_datum_updates/1
	# PUT /birth_datum_updates/1.xml
	def update
	#	@birth_datum_update = BirthDatumUpdate.find(params[:id])

		@birth_datum_update.update_attributes!(params[:birth_datum_update])
		flash[:notice] = 'Success!'
		redirect_to birth_datum_updates_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the birth_datum_update"
		render :action => "edit"

#		respond_to do |format|
#			if @birth_datum_update.update_attributes(params[:birth_datum_update])
#				format.html { redirect_to(@birth_datum_update, :notice => 'BirthDatumUpdate was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @birth_datum_update.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# DELETE /birth_datum_updates/1
	# DELETE /birth_datum_updates/1.xml
	def destroy
#		@birth_datum_update = BirthDatumUpdate.find(params[:id])
		@birth_datum_update.destroy
		redirect_to(birth_datum_updates_path)

#		respond_to do |format|
#			format.html { redirect_to(birth_datum_updates_url) }
#			format.xml	{ head :ok }
#		end
	end

	def parse
		if !@birth_datum_update.csv_file_file_name.blank? &&
				File.exists?(@birth_datum_update.csv_file.path)
			@results = @birth_datum_update.to_candidate_controls
			f=FasterCSV.open(@birth_datum_update.csv_file.path,'rb',{:headers => true })
			@csv_lines = f.readlines
			f.close
		else
			flash[:error] = "Birth Datum csv file not found."
			redirect_to @birth_datum_update
		end
	end

protected

	def valid_id_required
		if( !params[:id].blank? && BirthDatumUpdate.exists?(params[:id]) )
			@birth_datum_update = BirthDatumUpdate.find(params[:id])
		else
			access_denied("Valid id required!", birth_datum_updates_path)
		end
	end

end
