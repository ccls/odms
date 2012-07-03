class InterviewOutcomesController < ApplicationController

	before_filter :may_create_interview_outcomes_required,
		:only => [:new,:create]
	before_filter :may_read_interview_outcomes_required,
		:only => [:show,:index]
	before_filter :may_update_interview_outcomes_required,
		:only => [:edit,:update]
	before_filter :may_destroy_interview_outcomes_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@interview_outcomes = InterviewOutcome.scoped
	end

	def new
		@interview_outcome = InterviewOutcome.new(params[:interview_outcome])
	end

	def create
		@interview_outcome = InterviewOutcome.new(params[:interview_outcome])
		@interview_outcome.save!
		flash[:notice] = 'Success!'
		redirect_to @interview_outcome
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the interview_outcome"
		render :action => "new"
	end 

	def update
		@interview_outcome.update_attributes!(params[:interview_outcome])
		flash[:notice] = 'Success!'
		redirect_to interview_outcomes_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the interview_outcome"
		render :action => "edit"
	end

	def destroy
		@interview_outcome.destroy
		redirect_to interview_outcomes_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && InterviewOutcome.exists?(params[:id]) )
			@interview_outcome = InterviewOutcome.find(params[:id])
		else
			access_denied("Valid id required!", interview_outcomes_path)
		end
	end

end
