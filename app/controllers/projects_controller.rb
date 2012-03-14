class ProjectsController < ApplicationController

	before_filter :may_create_projects_required,
		:only => [:new,:create]
	before_filter :may_read_projects_required,
		:only => [:show,:index]
	before_filter :may_update_projects_required,
		:only => [:edit,:update]
	before_filter :may_destroy_projects_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@projects = Project.all
	end

	def new
		@project = Project.new
	end

	def create
		@project = Project.new(params[:project])
		@project.save!
		flash[:notice] = 'Success!'
		redirect_to @project
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating " <<
			"the project"
		render :action => "new"
	end 

	def update
		@project.update_attributes!(params[:project])
		flash[:notice] = 'Success!'
		redirect_to projects_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating " <<
			"the project"
		render :action => "edit"
	end

	def destroy
		@project.destroy
		redirect_to projects_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && Project.exists?(params[:id]) )
			@project = Project.find(params[:id])
		else
			access_denied("Valid id required!", projects_path)
		end
	end

end
