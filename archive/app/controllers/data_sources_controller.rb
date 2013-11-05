class DataSourcesController < ApplicationController

	before_filter :may_create_data_sources_required,
		:only => [:new,:create]
	before_filter :may_read_data_sources_required,
		:only => [:show,:index]
	before_filter :may_update_data_sources_required,
		:only => [:edit,:update]
	before_filter :may_destroy_data_sources_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@data_sources = DataSource.scoped
	end

	def new
		@data_source = DataSource.new(params[:data_source])
	end

	def create
		@data_source = DataSource.new(params[:data_source])
		@data_source.save!
		flash[:notice] = 'Success!'
		redirect_to @data_source
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the data_source"
		render :action => "new"
	end 

	def update
		@data_source.update_attributes!(params[:data_source])
		flash[:notice] = 'Success!'
		redirect_to data_sources_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the data_source"
		render :action => "edit"
	end

	def destroy
		@data_source.destroy
		redirect_to data_sources_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && DataSource.exists?(params[:id]) )
			@data_source = DataSource.find(params[:id])
		else
			access_denied("Valid id required!", data_sources_path)
		end
	end

end
