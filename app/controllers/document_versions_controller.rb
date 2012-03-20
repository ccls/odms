class DocumentVersionsController < ApplicationController

	before_filter :may_create_document_versions_required,
		:only => [:new,:create]
	before_filter :may_read_document_versions_required,
		:only => [:show,:index]
	before_filter :may_update_document_versions_required,
		:only => [:edit,:update]
	before_filter :may_destroy_document_versions_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@document_versions = DocumentVersion.order('position')
	end

	def new
		@document_version = DocumentVersion.new
	end

	def create
		@document_version = DocumentVersion.new(params[:document_version])
		@document_version.save!
		flash[:notice] = 'Success!'
		redirect_to @document_version
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating " <<
			"the document version"
		render :action => "new"
	end 

	def update
		@document_version.update_attributes!(params[:document_version])
		flash[:notice] = 'Success!'
		redirect_to document_versions_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating " <<
			"the document version"
		render :action => "edit"
	end

	def destroy
		@document_version.destroy
		redirect_to document_versions_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && DocumentVersion.exists?(params[:id]) )
			@document_version = DocumentVersion.find(params[:id])
		else
			access_denied("Valid id required!", document_versions_path)
		end
	end

end
