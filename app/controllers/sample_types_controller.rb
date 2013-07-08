class SampleTypesController < ApplicationController

	before_filter :may_create_sample_types_required,
		:only => [:new,:create]
	before_filter :may_read_sample_types_required,
		:only => [:show,:index]
	before_filter :may_update_sample_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_sample_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@sample_types = SampleType.roots.order('id ASC')
	end

	def new
		@sample_type = SampleType.new(params[:sample_type])
	end

	def create
		@sample_type = SampleType.new(params[:sample_type])
		@sample_type.save!
		flash[:notice] = 'Success!'
		redirect_to @sample_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample_type"
		render :action => "new"
	end 

	def update
		@sample_type.update_attributes!(params[:sample_type])
		flash[:notice] = 'Success!'
		redirect_to sample_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the sample_type"
		render :action => "edit"
	end

	def destroy
		@sample_type.destroy
		redirect_to sample_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SampleType.exists?(params[:id]) )
			@sample_type = SampleType.find(params[:id])
		else
			access_denied("Valid id required!", sample_types_path)
		end
	end

end
