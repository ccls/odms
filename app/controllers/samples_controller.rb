class SamplesController < ApplicationController

	before_filter :may_create_samples_required,
		:only => [:new,:create]
	before_filter :may_read_samples_required,
		:only => [:show,:index,:dashboard,:find,:followup,:reports]
	before_filter :may_update_samples_required,
		:only => [:edit,:update]
	before_filter :may_destroy_samples_required,
		:only => :destroy

	before_filter :valid_study_subject_id_required,
		:only => [:new,:create,:index]
#		:except => [:dashboard,:find,:followup,:reports,:edit,:update,:show,:destroy]

	before_filter :valid_id_required,
		:only => [:show,:edit,:update,:destroy]

	def index
		@samples = @study_subject.samples
		render :layout => 'subject'
	end

	def show
		render :layout => 'subject'
	end

	def new
		@sample = Sample.new
		render :layout => 'subject'
	end

	def create
		@sample = @study_subject.samples.new(params[:sample])
		@sample.save!
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample creation failed."
		render :action => 'new', :layout => 'subject'
	end

	def edit
		render :layout => 'subject'
	end

	def update
		@sample.update_attributes!(params[:sample])
		redirect_to sample_path(@sample)
	rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
		flash.now[:error] = "Sample update failed."
		render :action => 'edit', :layout => 'subject'
	end

	def destroy
		@sample.destroy
		redirect_to study_subject_path(@study_subject)
	end

protected

	def valid_id_required
		if !params[:id].blank? and Sample.exists?(params[:id])
			@sample = Sample.find(params[:id])
			@study_subject = @sample.study_subject
##	in dev on brg, above fails so being more explicit, the below works
#			@study_subject = StudySubject.find(@sample.study_subject_id)
		else
			access_denied("Valid sample id required!", study_subjects_path)
		end
	end

end
