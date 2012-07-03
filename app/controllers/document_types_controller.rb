class DocumentTypesController < ApplicationController

	before_filter :may_create_document_types_required,
		:only => [:new,:create]
	before_filter :may_read_document_types_required,
		:only => [:show,:index]
	before_filter :may_update_document_types_required,
		:only => [:edit,:update]
	before_filter :may_destroy_document_types_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@document_types = DocumentType.scoped
	end

	def new
		@document_type = DocumentType.new(params[:document_type])
	end

	def create
		@document_type = DocumentType.new(params[:document_type])
		@document_type.save!
		flash[:notice] = 'Success!'
		redirect_to @document_type
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the document_type"
		render :action => "new"
	end 

	def update
		@document_type.update_attributes!(params[:document_type])
		flash[:notice] = 'Success!'
		redirect_to document_types_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the document_type"
		render :action => "edit"
	end

	def destroy
		@document_type.destroy
		redirect_to document_types_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && DocumentType.exists?(params[:id]) )
			@document_type = DocumentType.find(params[:id])
		else
			access_denied("Valid id required!", document_types_path)
		end
	end

end
