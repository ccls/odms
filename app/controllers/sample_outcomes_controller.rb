class SampleOutcomesController < ApplicationController

	before_filter :may_create_sample_outcomes_required,
		:only => [:new,:create]
	before_filter :may_read_sample_outcomes_required,
		:only => [:show,:index]
	before_filter :may_update_sample_outcomes_required,
		:only => [:edit,:update]
	before_filter :may_destroy_sample_outcomes_required,
		:only => :destroy

	before_filter :valid_id_required, 
		:only => [:show,:edit,:update,:destroy]

	def index
		@sample_outcomes = SampleOutcome.all
	end

	def new
		@sample_outcome = SampleOutcome.new(params[:sample_outcome])
	end

	def create
		@sample_outcome = SampleOutcome.new(params[:sample_outcome])
		@sample_outcome.save!
		flash[:notice] = 'Success!'
		redirect_to @sample_outcome
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem creating the sample_outcome"
		render :action => "new"
	end 

	def update
		@sample_outcome.update_attributes!(params[:sample_outcome])
		flash[:notice] = 'Success!'
		redirect_to sample_outcomes_path
	rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
		flash.now[:error] = "There was a problem updating the sample_outcome"
		render :action => "edit"
	end

	def destroy
		@sample_outcome.destroy
		redirect_to sample_outcomes_path
	end

protected

	def valid_id_required
		if( !params[:id].blank? && SampleOutcome.exists?(params[:id]) )
			@sample_outcome = SampleOutcome.find(params[:id])
		else
			access_denied("Valid id required!", sample_outcomes_path)
		end
	end

end
