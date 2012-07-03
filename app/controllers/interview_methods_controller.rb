class InterviewMethodsController < ApplicationController

	before_filter :may_create_interview_methods_required,
		:only => [:new,:create]
	before_filter :may_read_interview_methods_required,
		:only => [:show,:index]
	before_filter :may_update_interview_methods_required,
		:only => [:edit,:update]
	before_filter :may_destroy_interview_methods_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@interview_methods = InterviewMethod.scoped
	end

	def new
		@interview_method = InterviewMethod.new(params[:interview_method])
	end

	def create
		@interview_method = InterviewMethod.new(params[:interview_method])
		@interview_method.save!
		flash[:notice] = 'Success!'
		redirect_to @interview_method
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the interview_method"
		render :action => "new"
	end 

	def update
		@interview_method.update_attributes!(params[:interview_method])
		flash[:notice] = 'Success!'
		redirect_to interview_methods_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the interview_method"
		render :action => "edit"
	end

	def destroy
		@interview_method.destroy
		redirect_to interview_methods_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && InterviewMethod.exists?(params[:id]) )
			@interview_method = InterviewMethod.find(params[:id])
		else
			access_denied("Valid id required!", interview_methods_path)
		end
	end

end
