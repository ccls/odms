class SectionsController < ApplicationController

	before_filter :may_create_sections_required,
		:only => [:new,:create]
	before_filter :may_read_sections_required,
		:only => [:show,:index]
	before_filter :may_update_sections_required,
		:only => [:edit,:update]
	before_filter :may_destroy_sections_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@sections = Section.all
	end

	def new
		@section = Section.new(params[:section])
	end

	def create
		@section = Section.new(params[:section])
		@section.save!
		flash[:notice] = 'Success!'
		redirect_to @section
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the section"
		render :action => "new"
	end 

	def update
		@section.update_attributes!(params[:section])
		flash[:notice] = 'Success!'
		redirect_to sections_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the section"
		render :action => "edit"
	end

	def destroy
		@section.destroy
		redirect_to sections_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Section.exists?(params[:id]) )
			@section = Section.find(params[:id])
		else
			access_denied("Valid id required!", sections_path)
		end
	end

end
