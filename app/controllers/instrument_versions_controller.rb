class InstrumentVersionsController < ApplicationController

	before_filter :may_create_instrument_versions_required,
		:only => [:new,:create]
	before_filter :may_read_instrument_versions_required,
		:only => [:show,:index]
	before_filter :may_update_instrument_versions_required,
		:only => [:edit,:update]
	before_filter :may_destroy_instrument_versions_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@instrument_versions = InstrumentVersion.all
	end

	def new
		@instrument_version = InstrumentVersion.new(params[:instrument_version])
	end

	def create
		@instrument_version = InstrumentVersion.new(params[:instrument_version])
		@instrument_version.save!
		flash[:notice] = 'Success!'
		redirect_to @instrument_version
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the instrument_version"
		render :action => "new"
	end 

	def update
		@instrument_version.update_attributes!(params[:instrument_version])
		flash[:notice] = 'Success!'
		redirect_to instrument_versions_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the instrument_version"
		render :action => "edit"
	end

	def destroy
		@instrument_version.destroy
		redirect_to instrument_versions_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && InstrumentVersion.exists?(params[:id]) )
			@instrument_version = InstrumentVersion.find(params[:id])
		else
			access_denied("Valid id required!", instrument_versions_path)
		end
	end

end
