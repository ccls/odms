class GuidesController < ApplicationController

	before_filter :may_create_guides_required,
		:only => [:new,:create]
	before_filter :may_read_guides_required,
		:only => [:show,:index]
	before_filter :may_update_guides_required,
		:only => [:edit,:update]
	before_filter :may_destroy_guides_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@guides = Guide.order('controller ASC, action ASC')
	end

	def new
		@guide = Guide.new(params[:guide])
	end

	def create
		@guide = Guide.new(params[:guide])
		@guide.save!
		flash[:notice] = 'Success!'
		redirect_to @guide
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the guide"
		render :action => "new"
	end 

	def update
		@guide.update_attributes!(params[:guide])
		flash[:notice] = 'Success!'
		redirect_to guides_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the guide"
		render :action => "edit"
	end

	def destroy
		@guide.destroy
		redirect_to guides_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Guide.exists?(params[:id]) )
			@guide = Guide.find(params[:id])
		else
			access_denied("Valid id required!", guides_path)
		end
	end

end
