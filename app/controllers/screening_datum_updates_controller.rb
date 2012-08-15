class ScreeningDatumUpdatesController < ApplicationController

	before_filter :may_create_screening_datum_updates_required,
		:only => [:new,:create,:parse]
	before_filter :may_read_screening_datum_updates_required,
		:only => [:show,:index]
	before_filter :may_update_screening_datum_updates_required,
		:only => [:edit,:update]
	before_filter :may_destroy_screening_datum_updates_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy,:parse]


	def index
		@screening_datum_updates = ScreeningDatumUpdate.scoped
	end

	def show
	end

	def new
		@screening_datum_update = ScreeningDatumUpdate.new
	end

	def create
		@screening_datum_update = ScreeningDatumUpdate.new(params[:screening_datum_update])
		@screening_datum_update.save!
		flash[:notice] = 'Success!'
		redirect_to @screening_datum_update
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the screening_datum_update"
		render :action => "new"
	rescue CSV::MalformedCSVError => e
		flash.now[:error] = "CSV error.<br/>#{e}".html_safe
		render :action => 'new'
	end

#	Edit/Update pointless as parsing is now automatic and AFTER CREATE

#	def edit
#	end
#
#	def update
#		@screening_datum_update.update_attributes!(params[:screening_datum_update])
#		flash[:notice] = 'Success!'
#		redirect_to screening_datum_updates_path
#	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
#		flash.now[:error] = "There was a problem updating the screening_datum_update"
#		render :action => "edit"
#	end

	def destroy
		@screening_datum_update.destroy
		redirect_to(screening_datum_updates_path)
	end

#	def parse
#		if !@screening_datum_update.csv_file_file_name.blank? &&
#				File.exists?(@screening_datum_update.csv_file.path)
#			@results = @screening_datum_update.to_candidate_controls
#			f=CSV.open(@screening_datum_update.csv_file.path,'rb',{:headers => true })
#			@csv_lines = f.readlines
#			f.close
#		else
#			flash[:error] = "Screening Datum csv file not found."
#			redirect_to @screening_datum_update
#		end
#	end

protected

	def valid_id_required
		if( !params[:id].blank? && ScreeningDatumUpdate.exists?(params[:id]) )
			@screening_datum_update = ScreeningDatumUpdate.find(params[:id])
		else
			access_denied("Valid id required!", screening_datum_updates_path)
		end
	end

end
