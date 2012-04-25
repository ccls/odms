class ProjectOutcomesController < ApplicationController

	before_filter :may_create_project_outcomes_required,
		:only => [:new,:create]
	before_filter :may_read_project_outcomes_required,
		:only => [:show,:index]
	before_filter :may_update_project_outcomes_required,
		:only => [:edit,:update]
	before_filter :may_destroy_project_outcomes_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@project_outcomes = ProjectOutcome.all
	end

	def new
		@project_outcome = ProjectOutcome.new(params[:project_outcome])
	end

	def create
		@project_outcome = ProjectOutcome.new(params[:project_outcome])
		@project_outcome.save!
		flash[:notice] = 'Success!'
		redirect_to @project_outcome
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the project_outcome"
		render :action => "new"
	end 

	def update
		@project_outcome.update_attributes!(params[:project_outcome])
		flash[:notice] = 'Success!'
		redirect_to project_outcomes_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the project_outcome"
		render :action => "edit"
	end

	def destroy
		@project_outcome.destroy
		redirect_to project_outcomes_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && ProjectOutcome.exists?(params[:id]) )
			@project_outcome = ProjectOutcome.find(params[:id])
		else
			access_denied("Valid id required!", project_outcomes_path)
		end
	end

end
