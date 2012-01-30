class LiveBirthDatasController < ApplicationController

	before_filter :may_create_live_birth_datas_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_live_birth_datas_required,
		:only => [:show,:index]
	before_filter :may_update_live_birth_datas_required,
		:only => [:edit,:update]
	before_filter :may_destroy_live_birth_datas_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]



	# GET /live_birth_datas
	# GET /live_birth_datas.xml
	def index
		@live_birth_datas = LiveBirthData.all

#		respond_to do |format|
#			format.html # index.html.erb
#			format.xml	{ render :xml => @live_birth_datas }
#		end
	end

	# GET /live_birth_datas/1
	# GET /live_birth_datas/1.xml
	def show
#		@live_birth_data = LiveBirthData.find(params[:id])
#
#		respond_to do |format|
#			format.html # show.html.erb
#			format.xml	{ render :xml => @live_birth_data }
#		end
	end

	# GET /live_birth_datas/new
	# GET /live_birth_datas/new.xml
	def new
		@live_birth_data = LiveBirthData.new
#
#		respond_to do |format|
#			format.html # new.html.erb
#			format.xml	{ render :xml => @live_birth_data }
#		end
	end

	# POST /live_birth_datas
	# POST /live_birth_datas.xml
	def create
		@live_birth_data = LiveBirthData.new(params[:live_birth_data])

		@live_birth_data.save!
		flash[:notice] = 'Success!'
		redirect_to @live_birth_data
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the live_birth_data"
		render :action => "new"


#		respond_to do |format|
#			if @live_birth_data.save
#				format.html { redirect_to(@live_birth_data, :notice => 'LiveBirthData was successfully created.') }
#				format.xml	{ render :xml => @live_birth_data, :status => :created, :location => @live_birth_data }
#			else
#				format.html { render :action => "new" }
#				format.xml	{ render :xml => @live_birth_data.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# GET /live_birth_datas/1/edit
	def edit
#		@live_birth_data = LiveBirthData.find(params[:id])
	end

	# PUT /live_birth_datas/1
	# PUT /live_birth_datas/1.xml
	def update
	#	@live_birth_data = LiveBirthData.find(params[:id])

		@live_birth_data.update_attributes!(params[:live_birth_data])
		flash[:notice] = 'Success!'
		redirect_to live_birth_datas_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the live_birth_data"
		render :action => "edit"

#		respond_to do |format|
#			if @live_birth_data.update_attributes(params[:live_birth_data])
#				format.html { redirect_to(@live_birth_data, :notice => 'LiveBirthData was successfully updated.') }
#				format.xml	{ head :ok }
#			else
#				format.html { render :action => "edit" }
#				format.xml	{ render :xml => @live_birth_data.errors, :status => :unprocessable_entity }
#			end
#		end
	end

	# DELETE /live_birth_datas/1
	# DELETE /live_birth_datas/1.xml
	def destroy
#		@live_birth_data = LiveBirthData.find(params[:id])
		@live_birth_data.destroy
		redirect_to(live_birth_datas_path)

#		respond_to do |format|
#			format.html { redirect_to(live_birth_datas_url) }
#			format.xml	{ head :ok }
#		end
	end

	def parse
		if !@live_birth_data.csv_file_file_name.blank? &&
				File.exists?(@live_birth_data.csv_file.path)
			@results = @live_birth_data.to_candidate_controls
			f=FasterCSV.open(@live_birth_data.csv_file.path,'rb',{:headers => true })
			@csv_lines = f.readlines
			f.close
		else
			flash[:error] = "Live Birth Data csv file not found."
			redirect_to @live_birth_data
		end
	end

protected

	def valid_id_required
		if( !params[:id].blank? && LiveBirthData.exists?(params[:id]) )
			@live_birth_data = LiveBirthData.find(params[:id])
		else
			access_denied("Valid id required!", live_birth_datas_path)
		end
	end

end
