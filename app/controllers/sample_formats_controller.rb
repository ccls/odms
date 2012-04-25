class SampleFormatsController < ApplicationController

	before_filter :may_create_sample_formats_required,
		:only => [:new,:create]
	before_filter :may_read_sample_formats_required,
		:only => [:show,:index]
	before_filter :may_update_sample_formats_required,
		:only => [:edit,:update]
	before_filter :may_destroy_sample_formats_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@sample_formats = SampleFormat.all
	end

	def new
		@sample_format = SampleFormat.new(params[:sample_format])
	end

	def create
		@sample_format = SampleFormat.new(params[:sample_format])
		@sample_format.save!
		flash[:notice] = 'Success!'
		redirect_to @sample_format
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample_format"
		render :action => "new"
	end 

	def update
		@sample_format.update_attributes!(params[:sample_format])
		flash[:notice] = 'Success!'
		redirect_to sample_formats_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the sample_format"
		render :action => "edit"
	end

	def destroy
		@sample_format.destroy
		redirect_to sample_formats_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SampleFormat.exists?(params[:id]) )
			@sample_format = SampleFormat.find(params[:id])
		else
			access_denied("Valid id required!", sample_formats_path)
		end
	end

end
