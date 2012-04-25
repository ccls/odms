class InstrumentVersionsController < ApplicationController

	before_filter :may_create_instument_versions_required,
		:only => [:new,:create]
	before_filter :may_read_instument_versions_required,
		:only => [:show,:index]
	before_filter :may_update_instument_versions_required,
		:only => [:edit,:update]
	before_filter :may_destroy_instument_versions_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@instument_versions = InstrumentVersion.all
	end

	def new
		@instument_version = InstrumentVersion.new(params[:instument_version])
	end

	def create
		@instument_version = InstrumentVersion.new(params[:instument_version])
		@instument_version.save!
		flash[:notice] = 'Success!'
		redirect_to @instument_version
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the instument_version"
		render :action => "new"
	end 

	def update
		@instument_version.update_attributes!(params[:instument_version])
		flash[:notice] = 'Success!'
		redirect_to instument_versions_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the instument_version"
		render :action => "edit"
	end

	def destroy
		@instument_version.destroy
		redirect_to instument_versions_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && InstrumentVersion.exists?(params[:id]) )
			@instument_version = InstrumentVersion.find(params[:id])
		else
			access_denied("Valid id required!", instument_versions_path)
		end
	end

end
